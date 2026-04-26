# 8. Rundeck — OIDC SSO

Вход в Rundeck CE через Authentik (OIDC) с маппингом групп Authentik → Rundeck ACL ролей.

| Переменная | Описание |
|------------|----------|
| `RUNDECK_URL` | `https://rundeck.itruslan.ru` |
| `AUTHENTIK_URL` | `https://auth.itruslan.ru` |

## Архитектура

Rundeck CE сам OIDC не умеет — используем sidecar `oauth2-proxy` + preauthenticated mode:

```
browser → HTTPRoute → oauth2-proxy:4180 → rundeck:4440
                          │
                          ├─ редирект на Authentik если нет cookie
                          └─ при upstream-запросе кладёт X-Forwarded-User / X-Forwarded-Email / X-Forwarded-Groups
```

Rundeck читает заголовки через `rundeck.security.authorization.preauthenticated.*` и применяет ACL на основе групп.

Service `port: 4440` (rundeck) переопределён в кластерных values на `targetPort: 4180` — внешний трафик идёт в proxy, proxy локально проксирует на 4440.

## 1. Authentik OAuth provider

В `terraform/authentik/authentik-oauth-apps/terragrunt.hcl` добавить запись в `apps`:

```hcl
rundeck = {
  name        = "Rundeck"
  client_type = "public"   # PKCE, без client_secret
  allowed_redirect_uris = [
    "https://rundeck.${include.root.locals.domain}/oauth2/callback"
  ]
  vault_secret_path      = "authentik/apps/rundeck"
  generate_cookie_secret = true   # 32-байтный cookie secret для oauth2-proxy
}
```

```bash
cd terraform/authentik/authentik-oauth-apps
tg apply
```

Модуль создаст provider + application в Authentik и положит в Vault `secret/authentik/apps/rundeck`:

- `clientId`
- `clientSecret`
- `cookieSecret` (b64url)
- `issuerUrl`

## 2. Rundeck RBAC — группы Authentik

В `terraform/rundeck/rundeck-rbac/rbac.yaml`:

```yaml
groups:
  rundeck-admins:
    users:
      - itruslan
  rundeck-users:
    users: []
```

```bash
cd terraform/rundeck/rundeck-rbac
tg apply
```

Создаёт Authentik-группы `rundeck-admins` / `rundeck-users` и назначает в них пользователей. Имена групп = subjects в ACL (см. шаг 4).

Чтобы выдать доступ — добавить username в нужный список и `tg apply`.

## 3. Vault → Kubernetes secret

ExternalSecret `rundeck-oidc` в namespace `rundeck` забирает Vault path `secret/authentik/apps/rundeck` и кладёт в одноимённый Secret. Используется в deployment для oauth2-proxy env-vars (`OAUTH2_PROXY_CLIENT_ID/SECRET/COOKIE_SECRET`). reloader перезапустит Pod при ротации.

## 4. Helm values + ACL

В `clusters/homelab/rundeck/values.yaml`:

```yaml
service:
  targetPort: 4180     # gateway → oauth2-proxy

rundeck:
  grailsUrl: "https://rundeck.itruslan.ru"
  oidc:
    enabled: true
    authentikDomain: "auth.itruslan.ru"
    adminGroup: "rundeck-admins"
    allowUnverifiedEmail: "true"
  acl:
    enabled: true
```

ACL файлы: `charts/infra/rundeck/files/policies/*.aclpolicy`. По одному файлу на роль. Subject — `by: group: <authentik-group-name>`. Файлы монтируются в `/home/rundeck/etc/` (где Rundeck читает по `framework.etc.dir`), **не** в `/home/rundeck/server/config/` — иначе `REJECTED_NO_SUBJECT_OR_ENV_FOUND`.

Для admin-роли нужны два документа в одном файле:

1. `context: project: '.*'` — права внутри проектов
2. `context: application: 'rundeck'` — права на system/system_acl/user/job/plugin/project/storage

Без второго документа после логина выводится «You have no authorized access to projects».

## 5. Sync и проверка

```bash
argocd app sync homelab-rundeck --grpc-web
```

Логин: `https://rundeck.itruslan.ru` → редирект на Authentik → callback `/oauth2/callback`.

Logout: `/oauth2/sign_out` (preauth настроен на `redirectLogout=true` + `redirectUrl=/oauth2/sign_out`).

Если «no access» — смотреть лог rundeck-контейнера на загрузку ACL и `subject<...>` строку в Decision-логах:

```bash
kubectl -n rundeck logs deploy/rundeck -c rundeck | grep -E 'aclpolicy|subject<'
```

## Гранулярные нюансы

- **Headers**: oauth2-proxy v7.6.0 в reverse-proxy режиме передаёт upstream только `X-Forwarded-*`. `X-Auth-Request-*` — это response-headers (для nginx `auth_request`), Rundeck их не получит. preauth.properties должен ссылаться на `X-Forwarded-User/Email/Groups`.
- **Groups scope**: модуль `authentik-oauth-apps` цепляет к provider общий property mapping `groups-oauth-apps` (scope `groups`). oauth2-proxy запрашивает `openid profile email groups`.
- **Public client**: `client_type = "public"` + PKCE — для oauth2-proxy достаточно, secret в Vault всё равно лежит, но Authentik не требует его обязательным.
- **Reloader**: `stakater/reloader` иногда не реагирует на изменение ACL ConfigMap — `kubectl rollout restart deploy/rundeck -n rundeck` помогает.
- **subPath mount**: ACL файлы маунтятся через `subPath`, поэтому root-owned 644 — нормально.

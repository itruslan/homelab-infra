# 6. Authentik — bootstrap

Деплой Authentik через ArgoCD (GitOps) и настройка GitHub OAuth.

| Переменная | Описание |
|------------|----------|
| `AUTHENTIK_URL` | `https://auth.itruslan.ru` |
| `AUTHENTIK_TOKEN` | Bootstrap token из Vault (`secret/authentik/bootstrap`) |

## GitOps

Authentik деплоится через ArgoCD из `homelab-gitops/apps/authentik`.

Использует CNPG (CloudNative-PG) для PostgreSQL и ExternalSecrets для получения bootstrap credentials из Vault.

После деплоя UI доступен на `https://auth.itruslan.ru`.

## GitHub OAuth source

```bash
cd terraform/authentik/authentik-github-source
tg apply
```

Создаёт OAuth source для входа через GitHub. Credentials хранятся в Vault по пути `secret/authentik/github-source`.

После apply автоматически запускается `patch-default-stages.sh` — патчит enrollment flow через Authentik API (устанавливает `user_type=internal`).

## OAuth apps

```bash
cd terraform/authentik/authentik-oauth-apps
tg apply
```

Создаёт OIDC провайдеры и приложения в Authentik для:
- ArgoCD (`https://argocd.itruslan.ru`)
- Vault (`https://vault.itruslan.ru`)

Client secrets сохраняются в Vault.

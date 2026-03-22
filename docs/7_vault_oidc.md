# 7. Vault — OIDC auth

Настройка входа в Vault через Authentik (OIDC) и назначение политик пользователям.

| Переменная | Описание |
|------------|----------|
| `VAULT_ADDR` | `https://vault.itruslan.ru` |
| `VAULT_TOKEN` | Root или admin token |

## Vault listener — x_forwarded_for

Vault за load balancer'ом требует доверия к заголовку `X-Forwarded-For`.

В `homelab-gitops/apps/vault/values.yaml` в секции `listener "tcp"` должно быть:

```hcl
x_forwarded_for_authorized_addrs  = "0.0.0.0/0"
x_forwarded_for_reject_not_present = false
```

Без этого logout и redirect URI работают некорректно.

## vault-oidc-auth

```bash
cd terraform/vault/vault-oidc-auth
tg apply
```

Создаёт OIDC auth backend с дефолтной ролью `default`. Client credentials берутся из dependency `authentik-oauth-apps`.

UI доступен на `https://vault.itruslan.ru` — вкладка OIDC, поле Role оставить пустым.

## vault-user-policies

```bash
cd terraform/vault/vault-user-policies
tg apply
```

Создаёт Vault policies и identity entities для конкретных пользователей.

Каждый файл в `policies/` — один пользователь:
- Имя файла (без `.hcl`) = имя пользователя в Vault (OIDC `preferred_username`)
- Содержимое файла = Vault policy

Чтобы добавить пользователя — создать файл `policies/<username>.hcl`.

Если identity entity или alias уже существуют (созданы автоматически при первом OIDC-логине):

```bash
tg import 'vault_identity_entity.this["<username>"]' <entity-id>
tg import 'vault_identity_entity_alias.this["<username>"]' <alias-id>
```

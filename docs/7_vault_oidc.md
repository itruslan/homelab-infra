# 7. Vault — OIDC auth

Настройка входа в Vault через Authentik (OIDC) и назначение политик пользователям.

| Переменная | Описание |
|------------|----------|
| `VAULT_ADDR` | `https://vault.itruslan.ru` |
| `VAULT_TOKEN` | Root или admin token |

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

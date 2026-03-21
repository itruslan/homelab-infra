# 3. Proxmox — bootstrap

Создаём Terraform пользователя, роль и API токен.
Bootstrap модуль использует `root@pam` — после apply переключаемся на токен.

## Переменные окружения

Заполнить в `.envrc`:

```bash
export PROXMOX_VE_ENDPOINT=https://pve-1.itruslan.ru:8006
export PROXMOX_VE_USERNAME=root@pam
export PROXMOX_VE_PASSWORD="<root password>"
```

## proxmox-auth

```bash
cd terraform/proxmox/proxmox-auth
tg apply
```

После apply получить токен:

```bash
tg output -json proxmox_users | jq -r '.terraform.token_id + "=" + .terraform.token'
```

Добавить токен в `.envrc`, убрать `PROXMOX_VE_USERNAME` и `PROXMOX_VE_PASSWORD`:

```bash
export PROXMOX_VE_API_TOKEN="terraform@pve!terraform=<token>"
```

Выполнить `direnv allow`. С этого момента все Proxmox модули используют токен.

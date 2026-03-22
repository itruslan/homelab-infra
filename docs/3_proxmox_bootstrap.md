# 3. Proxmox — bootstrap

Создаём Terraform пользователя и API токен через `root@pam`.

| Переменная | Описание |
|------------|----------|
| `PROXMOX_VE_ENDPOINT` | URL Proxmox API (`https://pve-1.itruslan.ru:8006`) |
| `PROXMOX_VE_USERNAME` | `root@pam` (только для bootstrap) |
| `PROXMOX_VE_PASSWORD` | Пароль root |
| `PROXMOX_VE_API_TOKEN` | Токен после bootstrap (`terraform@pve!terraform=<token>`) |

## proxmox-svc

```bash
cd terraform/proxmox/proxmox-svc
tg apply
tg output -json proxmox_users | jq -r '.terraform.token_id + "=" + .terraform.token'
```

Добавить `PROXMOX_VE_API_TOKEN` в `.envrc`, убрать `PROXMOX_VE_USERNAME` и `PROXMOX_VE_PASSWORD`.

## proxmox-vm-k8s-masters / proxmox-vm-k8s-workers

```bash
cd terraform/proxmox/proxmox-vm-k8s-masters
tg apply

cd ../proxmox-vm-k8s-workers
tg apply
```

## proxmox-oidc-auth / proxmox-users

> Применять после `authentik-oauth-apps` (docs/6).

```bash
cd terraform/proxmox/proxmox-oidc-auth
tg apply

cd ../proxmox-users
tg apply
```

# 2. Yandex Cloud — bootstrap

Создаём папку и S3 бакет для Terraform state.
Эти модули используют локальный state — S3 бакет ещё не существует.

## yc-folder

```bash
cd terraform/yandex-cloud/yc-folder

# Если папка уже существует — импортируем
tg import yandex_resourcemanager_folder.folder <FOLDER_ID>

tg apply
```

## yc-s3-tf-state

```bash
cd terraform/yandex-cloud/yc-s3-tf-state
tg apply
```

После apply:

1. Скопировать `rw_sa_access_key` / `rw_sa_secret_key` из outputs в AWS CLI профиль `homelab`:

```bash
aws configure --profile homelab
# AWS Access Key ID: <rw_sa_access_key>
# AWS Secret Access Key: <rw_sa_secret_key>
```

2. Заполнить `TF_STATE_BUCKET` в `.envrc` и выполнить `direnv allow`

С этого момента все модули автоматически используют S3 backend.

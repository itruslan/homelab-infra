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

Перед apply заполнить `TF_STATE_BUCKET` в `.envrc` и выполнить `direnv allow`.

```bash
cd terraform/yandex-cloud/yc-s3-tf-state
tg apply
```

После apply:

1. Скопировать `storage_admin_access_key` / `storage_admin_secret_key` из outputs в AWS CLI профиль `homelab-infra`:

```bash
tg output -raw storage_admin_secret_key

aws configure --profile homelab-infra
# AWS Access Key ID: <storage_admin_access_key>
# AWS Secret Access Key: <storage_admin_secret_key>
# Default region name: us-east-1
```

2. Добавить `AWS_PROFILE=homelab-infra` в `.envrc` и выполнить `direnv allow`

3. Мигрировать локальные state в S3:

```bash
cd terraform/yandex-cloud/yc-folder
tg init

cd ../yc-s3-tf-state
tg init -- -migrate-state
```

С этого момента все модули автоматически используют S3 backend.

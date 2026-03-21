# 2. Yandex Cloud — bootstrap

Создаём папку и S3 бакет для Terraform state. Оба модуля используют локальный state.

| Переменная | Описание |
|------------|----------|
| `TF_STATE_BUCKET` | Имя S3 бакета |
| `AWS_PROFILE` | AWS CLI профиль (`homelab-infra`) |

## yc-folder

```bash
cd terraform/yandex-cloud/yc-folder
tg import yandex_resourcemanager_folder.folder <FOLDER_ID>  # если папка уже существует
tg apply
```

## yc-s3-tf-state

Заполнить `TF_STATE_BUCKET` в `.envrc`, затем:

```bash
cd terraform/yandex-cloud/yc-s3-tf-state
tg apply
tg output -raw storage_admin_secret_key
aws configure --profile homelab-infra
```

Мигрировать state в S3:

```bash
cd terraform/yandex-cloud/yc-folder && tg init
cd ../yc-s3-tf-state && tg init -- -migrate-state
```

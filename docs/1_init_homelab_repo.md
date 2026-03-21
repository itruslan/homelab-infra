# 1. Инициализация репозитория

Зависимости: [mise](https://mise.jdx.dev/), [direnv](https://direnv.net/), [yc cli](https://cloud.yandex.ru/docs/cli/quickstart)

```bash
mise install
cp .envrc.example .envrc
direnv allow
```

| Переменная | Описание |
|------------|----------|
| `YC_TOKEN` | `yc iam create-token` |
| `YC_CLOUD_ID` | `yc resource-manager cloud list` |
| `AWS_PROFILE` | AWS CLI профиль для YC Object Storage |
| `TF_STATE_BUCKET` | Имя S3 бакета для Terraform state |
| `MODULES_LOCAL_PATH` | Локальный путь к terraform-modules (для разработки) |

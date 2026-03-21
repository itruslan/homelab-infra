# 1. Инициализация репозитория

## Зависимости

- [mise](https://mise.jdx.dev/) — менеджер версий инструментов
- [direnv](https://direnv.net/) — автозагрузка `.envrc`
- [yc cli](https://cloud.yandex.ru/docs/cli/quickstart) — Yandex Cloud CLI

## Настройка

```bash
mise install
cp .envrc.example .envrc
direnv allow
```

## Переменные окружения

| Переменная | Описание |
|------------|----------|
| `YC_TOKEN` | IAM токен Yandex Cloud (`yc iam create-token`) |
| `YC_CLOUD_ID` | ID облака (`yc resource-manager cloud list`) |
| `AWS_PROFILE` | AWS CLI профиль со статическими ключами YC Object Storage |
| `TF_STATE_BUCKET` | Имя S3 бакета для Terraform state |
| `MODULES_LOCAL_PATH` | Локальный путь к terraform-modules (для разработки) |

# homelab-infra

Homelab infrastructure as code — built step by step from scratch.

## Docs

- [1. Init homelab repo](docs/1_init_homelab_repo.md)
- [2. Yandex Cloud bootstrap](docs/2_yandex_cloud_bootstrap.md)

## Structure

```
terraform/
├── root.hcl
└── yandex-cloud/
    ├── yc-folder/
    └── yc-s3-tf-state/
```

## Usage

```bash
cd terraform/<module>
tg plan
tg apply
```

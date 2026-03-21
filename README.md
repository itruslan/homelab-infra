# homelab-infra

Homelab infrastructure as code — built step by step from scratch.

## Dependencies

- [mise](https://mise.jdx.dev/) — manages tool versions from `.tool-versions`
- [direnv](https://direnv.net/) — loads `.envrc` automatically

```bash
mise install
cp .envrc.example .envrc  # fill in your values
direnv allow
```

## Structure

```
terraform/
├── root.hcl                    # remote state, common locals
├── yandex-cloud/
│   ├── yc-folder/              # homelab folder
│   └── yc-s3-tf-state/        # S3 bucket for Terraform state
├── mikrotik/
└── proxmox/
```

## Usage

```bash
cd terraform/<module>
tg plan
tg apply
```

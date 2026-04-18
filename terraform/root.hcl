locals {
  project     = "homelab"
  environment = "infra"

  yc_cloud_id = get_env("YC_CLOUD_ID")
  dns_servers = split(",", get_env("DNS_SERVERS"))
  domain      = get_env("DNS_DOMAIN")

  yc_vpc_id = "enprj3obbitl7a1n4t51"

  yc_subnets = [
    {
      zone = "ru-central1-a"
      id   = "e9bha8daq4e8nv9r8n80"
    },
    {
      zone = "ru-central1-b"
      id   = "e2l1d1h8iltqasvvci29"
    },
    {
      zone = "ru-central1-d"
      id   = "fl8hdt3f71jn766dvu6t"
    },
    {
      zone = "ru-central1-e"
      id   = "ajc7qpt0a5glssr5ai2g"
    },
  ]

  labels = {
    project     = local.project
    environment = local.environment
  }

  vault_address = "https://vault.${local.domain}"
}

terraform {
  after_hook "unquarantine_providers" {
    commands = ["init"]
    execute  = ["sh", "-c", "xattr -dr com.apple.quarantine ~/.terraform.d/plugin-cache 2>/dev/null; xattr -dr com.apple.quarantine .terraform 2>/dev/null; true"]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    endpoint                    = "https://storage.yandexcloud.net"
    bucket                      = get_env("TF_STATE_BUCKET")
    region                      = "us-east-1"
    key                         = "${path_relative_to_include()}/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    disable_bucket_update       = true
  }
}

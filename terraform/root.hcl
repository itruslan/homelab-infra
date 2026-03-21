locals {
  project     = "homelab"
  environment = "infra"

  yc_cloud_id = get_env("YC_CLOUD_ID")

  labels = {
    project     = local.project
    environment = local.environment
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

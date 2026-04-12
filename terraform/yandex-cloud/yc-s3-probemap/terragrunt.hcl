include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-storage-bucket.git?ref=v2.0.0"
}

generate "aws_provider" {
  path      = "aws_provider_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}
EOF
}

dependency "yc_folder" {
  config_path = "../yc-folder"

  mock_outputs = {
    folder_id = "mock-folder-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

locals {
  bucket_name = "itruslan-probemap"
}

inputs = {
  folder_id   = dependency.yc_folder.outputs.folder_id
  bucket_name = local.bucket_name

  versioning = {
    enabled = true
  }

  storage_admin_service_account = {
    name = "sa-${local.bucket_name}"
  }

  labels = include.root.locals.labels
}

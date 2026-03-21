include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}

locals {
  modules_local = get_env("MODULES_LOCAL_PATH", "")
  module_source = length(local.modules_local) > 0 ? "${local.modules_local}//yc-folder" : "git::https://github.com/rgadzhiev/terraform-modules.git//yc-folder?ref=main"
}

terraform {
  source = local.module_source
}

inputs = {
  cloud_id    = include.root.locals.yc_cloud_id
  name        = "homelab"
  description = "Homelab infrastructure"
  labels      = include.root.locals.labels
}

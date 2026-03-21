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

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//yc-folder?ref=main"
}

inputs = {
  cloud_id    = include.root.locals.yc_cloud_id
  name        = "homelab"
  description = "Homelab infrastructure"
  labels      = include.root.locals.labels
}

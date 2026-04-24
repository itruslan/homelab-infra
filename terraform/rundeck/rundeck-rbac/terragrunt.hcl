include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # temporary: local source until module is merged to main
  source = "/Users/rgadzhiev/GitHub/terraform-modules/authentik-rundeck-rbac"
}

inputs = {
  groups = yamldecode(file("${get_original_terragrunt_dir()}/rbac.yaml")).groups
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//yc-iam-sa?ref=main"
  # Development: use local path instead
  # source = "/Users/rgadzhiev/GitHub/terraform-modules/yc-iam-sa"
}

dependency "yc_folder" {
  config_path = "../yc-folder"

  mock_outputs = {
    folder_id = "mock-folder-id"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  folder_id   = dependency.yc_folder.outputs.folder_id
  sa_name     = "sa-rundeck"
  description = "Rundeck service account for managing Yandex Cloud resources"
  labels      = include.root.locals.labels

  # Permissions to discover (list) and start/stop/create VMs in the folder
  roles = [
    "compute.editor",
    "vpc.user",
    "iam.serviceAccounts.user",
  ]
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//rundeck-yc-scheduler?ref=main"
  #  Development: use local path instead
  #  source = "/Users/rgadzhiev/GitHub/terraform-modules/rundeck-yc-scheduler"
}

dependency "yc_folder" {
  config_path = "../../yandex-cloud/yc-folder"

  mock_outputs = {
    folder_id = "mock-folder-id"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "yc_iam_sa_rundeck" {
  config_path = "../../yandex-cloud/yc-iam-sa-rundeck"

  mock_outputs = {
    sa_key_json = "{}"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  rundeck_url        = "https://rundeck.${include.root.locals.domain}"
  rundeck_auth_token = get_env("RUNDECK_AUTH_TOKEN")

  projects = [
    {
      name         = "homelab"
      display_name = "Homelab"
      folder_id    = dependency.yc_folder.outputs.folder_id
      yc_sa_key    = dependency.yc_iam_sa_rundeck.outputs.sa_key_json
      time_zone    = "Europe/Moscow"

      stop_schedule  = "0 0 1 * * ? *"  # every day 01:00 MSK
      start_schedule = "0 0 6 * * ? *"  # every day 06:00 MSK

      resource_types = {
        compute-instance = {
          enabled    = true
          stop_order = 1
        }
      }
    }
  ]
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "yc_folder" {
  config_path = "../yc-folder"
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//yc-cm?ref=main"
}

inputs = {
  folder_id = dependency.yc_folder.outputs.folder_id
  zone_id   = get_env("CLOUDFLARE_ZONE_ID")
  api_token = get_env("CLOUDFLARE_API_TOKEN")

  name    = "teleport-itruslan-ru"
  domains = ["*.teleport.itruslan.ru"]
}

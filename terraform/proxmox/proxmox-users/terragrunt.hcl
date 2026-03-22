include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "proxmox" {
  path   = find_in_parent_folders("proxmox.hcl")
  expose = true
}

dependency "proxmox_oidc" {
  config_path = "../proxmox-oidc-auth"

  mock_outputs = {
    realm = "authentik"
  }
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//proxmox-users?ref=main"
}

inputs = {
  proxmox_endpoint = include.proxmox.locals.proxmox_endpoint

  groups = {
    admins = {
      comment = "Authentik OIDC admins"
      acls = [
        {
          path = "/"
          role = "Administrator"
        }
      ]
    }
  }

  users = {
    itruslan = {
      realm   = dependency.proxmox_oidc.outputs.realm
      groups  = ["admins"]
      comment = "itruslan (Authentik OIDC)"
    }
  }
}

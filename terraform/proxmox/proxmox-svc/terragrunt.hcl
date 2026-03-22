include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "proxmox" {
  path   = find_in_parent_folders("proxmox.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//proxmox-svc?ref=main"
}

inputs = {
  proxmox_endpoint = include.proxmox.locals.proxmox_endpoint

  roles = [
    {
      name = "TerraformRole"
      privileges = [
        "Datastore.AllocateSpace", "Datastore.AllocateTemplate", "Datastore.Audit",
        "Pool.Allocate", "Sys.Audit", "Sys.Console", "Sys.Modify",
        "Group.Allocate", "Permissions.Modify", "Realm.Allocate", "Realm.AllocateUser", "User.Modify",
        "VM.Allocate", "VM.Audit", "VM.Clone", "VM.Config.CDROM",
        "VM.Config.Cloudinit", "VM.Config.CPU", "VM.Config.Disk",
        "VM.Config.HWType", "VM.Config.Memory", "VM.Config.Network",
        "VM.Config.Options", "VM.Migrate", "VM.PowerMgmt",
        "SDN.Use",
      ]
    }
  ]

  users = [
    {
      name       = "terraform"
      role       = "TerraformRole"
      token_name = "terraform"
    }
  ]
}

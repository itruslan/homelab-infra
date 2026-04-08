include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "proxmox" {
  path   = find_in_parent_folders("proxmox.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//proxmox-vm?ref=main"
}

inputs = {
  name             = "oc-client"
  proxmox_endpoint = include.proxmox.locals.proxmox_endpoint

  cpu    = 2
  memory = 2

  main_disk_storage = "local-lvm"
  main_disk_size    = 50

  clone          = include.proxmox.locals.clone
  initialization = include.proxmox.locals.initialization

  tags = ["openconnect"]

  vm_list = [
    {
      name_suffix  = "1"
      node_name    = "pve-1"
      vm_id        = 101
      ipv4_address = "192.168.99.101/24"
    },
  ]
}

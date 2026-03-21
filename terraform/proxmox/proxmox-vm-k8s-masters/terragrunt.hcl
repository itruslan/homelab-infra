include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "proxmox" {
  path   = find_in_parent_folders("proxmox.hcl")
  expose = true
}

locals {
  module_source = length(include.proxmox.locals.modules_local) > 0 ? "${include.proxmox.locals.modules_local}//proxmox-vm" : "git::https://github.com/itruslan/terraform-modules.git//proxmox-vm?ref=main"
}

terraform {
  source = local.module_source
}

inputs = {
  name             = "k8s-master"
  proxmox_endpoint = include.proxmox.locals.proxmox_endpoint

  cpu    = 2
  memory = 4

  main_disk_storage = "local-lvm"
  main_disk_size    = 50

  clone          = include.proxmox.locals.clone
  initialization = include.proxmox.locals.initialization

  tags = ["k8s", "master", "homelab"]

  vm_list = [
    {
      name_suffix  = "1"
      node_name    = "pve-1"
      vm_id        = 201
      ipv4_address = "192.168.99.201/24"
    },
    {
      name_suffix  = "2"
      node_name    = "pve-2"
      vm_id        = 202
      ipv4_address = "192.168.99.202/24"
    },
    {
      name_suffix  = "3"
      node_name    = "pve-3"
      vm_id        = 203
      ipv4_address = "192.168.99.203/24"
    },
  ]
}

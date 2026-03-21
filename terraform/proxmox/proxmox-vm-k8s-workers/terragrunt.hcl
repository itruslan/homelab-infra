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
  name             = "k8s-worker"
  proxmox_endpoint = include.proxmox.locals.proxmox_endpoint

  cpu    = 4
  memory = 8

  main_disk_storage = "local-lvm"
  main_disk_size    = 100

  clone          = include.proxmox.locals.clone
  initialization = include.proxmox.locals.initialization

  tags = ["k8s", "worker", "homelab"]

  vm_list = [
    {
      name_suffix  = "1"
      node_name    = "pve-1"
      vm_id        = 211
      ipv4_address = "192.168.99.211/24"
    },
    {
      name_suffix  = "2"
      node_name    = "pve-2"
      vm_id        = 212
      ipv4_address = "192.168.99.212/24"
    },
    {
      name_suffix  = "3"
      node_name    = "pve-3"
      vm_id        = 213
      ipv4_address = "192.168.99.213/24"
    },
  ]
}

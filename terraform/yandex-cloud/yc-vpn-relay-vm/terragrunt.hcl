include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # terraform-yacloud-modules/terraform-yandex-instance
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-instance.git?ref=v2.20.0"
}

dependency "yc_folder" {
  config_path = "../yc-folder"

  mock_outputs = {
    folder_id = "mock-folder-id"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "yc_vpn_relay_sg" {
  config_path = "../yc-vpn-relay-sg"

  mock_outputs = {
    id = "mock-security-group-id"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

locals {
  zone = "ru-central1-e"
  ssh_pubkey_path = "/Users/rgadzhiev/.ssh/id_ed25519.pub"
  subnet_id = one([
    for subnet in include.root.locals.yc_subnets : subnet.id
    if subnet.zone == local.zone
  ])
}

inputs = {
  folder_id = dependency.yc_folder.outputs.folder_id

  name        = "homelab-vpn-relay"
  description = "VLESS Reality relay entry VM (VLESS->FreakHosting split routing)"
  labels      = include.root.locals.labels

  # Plan requires a new zone (E). Yandex VM module expects explicit zone id.
  zone = local.zone

  # Networking is centralized in terraform/root.hcl -> yc_vpc_id / yc_subnets.
  subnet_id          = local.subnet_id
  security_group_ids = [dependency.yc_vpn_relay_sg.outputs.id]

  # VM sizing: 2 vCPU, 2 GB RAM, preemptible.
  # terraform-yandex-instance uses platform_id rather than "Cascade Lake" string;
  # standard-v3 allows only 20/50/100 core fraction values.
  platform_id   = "standard-v3"
  cores         = 2
  core_fraction = 20
  memory        = 2
  preemptible   = true
  image_family  = "ubuntu-2404-lts"
  boot_disk_initialize_params = {
    type = "network-ssd"
  }

  # Make the VM reachable for bootstrap via public SSH.
  create_pip = true
  enable_nat = true

  # Use existing SSH username convention from homelab-infra.
  ssh_user         = get_env("VM_USERNAME")
  generate_ssh_key = false
  ssh_pubkey       = local.ssh_pubkey_path

  # k3s bootstrap will be handled by VPN-03 (avoid mixing concerns here).
  user_data = <<-EOT
#cloud-config
package_update: true
packages:
  - curl
runcmd:
  - curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --tls-san yc-vps.itruslan.ru" sh -
EOT
}

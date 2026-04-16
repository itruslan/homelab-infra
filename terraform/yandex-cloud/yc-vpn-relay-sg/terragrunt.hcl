include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-security-group.git?ref=v1.40.0"
}

dependency "yc_folder" {
  config_path = "../yc-folder"

  mock_outputs = {
    folder_id = "mock-folder-id"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

locals {
  admin_allowed_cidrs = compact(split(",", get_env("YC_ADMIN_ALLOWED_CIDRS", "128.0.142.231/32,191.96.94.9/32")))
}

inputs = {
  folder_id = dependency.yc_folder.outputs.folder_id

  blank_name  = "homelab-vpn-relay"
  description = "Security group for YC VPN relay VM"
  labels      = include.root.locals.labels

  vpc_id = include.root.locals.yc_vpc_id

  ingress_rules = {
    admin_all = {
      protocol       = "ANY"
      description    = "Allow all protocols and ports from trusted admin CIDRs"
      from_port      = 0
      to_port        = 65535
      v4_cidr_blocks = local.admin_allowed_cidrs
    }
  }

  egress_rules = {
    all_ipv4 = {
      protocol          = "ANY"
      description       = "Allow all outbound IPv4 traffic"
      v4_cidr_blocks    = ["0.0.0.0/0"]
      from_port         = 0
      to_port           = 65535
    }
  }
}

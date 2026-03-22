include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "proxmox" {
  path   = find_in_parent_folders("proxmox.hcl")
  expose = true
}

dependency "authentik_oauth_apps" {
  config_path = "../../authentik/authentik-oauth-apps"

  mock_outputs = {
    client_secrets = {
      proxmox = "mock-secret"
    }
    apps = {
      proxmox = {
        client_id   = "mock-client-id"
        issuer_path = "/application/o/proxmox/"
      }
    }
  }
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//proxmox-oidc-auth?ref=main"
}

locals {
  authentik_url = "https://auth.${include.root.locals.domain}"
}

inputs = {
  proxmox_endpoint = include.proxmox.locals.proxmox_endpoint

  issuer_url = "${local.authentik_url}/application/o/proxmox/"
  client_id  = dependency.authentik_oauth_apps.outputs.apps["proxmox"].client_id
  client_key = dependency.authentik_oauth_apps.outputs.client_secrets["proxmox"]
}

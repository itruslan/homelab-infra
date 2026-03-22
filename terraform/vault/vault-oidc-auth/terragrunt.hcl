include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "authentik_oauth_apps" {
  config_path = "../../authentik/authentik-oauth-apps"

  mock_outputs = {
    client_secrets = {
      vault = "mock-secret"
    }
    apps = {
      vault = {
        client_id   = "mock-client-id"
        issuer_path = "/application/o/vault/"
      }
    }
  }
}

terraform {
  # source = "git::https://github.com/itruslan/terraform-modules.git//vault-oidc-auth?ref=main"
  source = "/Users/rgadzhiev/GitHub/terraform-modules/vault-oidc-auth"
}

locals {
  authentik_url = "https://auth.${include.root.locals.domain}"
}

inputs = {
  vault_address = "https://vault.${include.root.locals.domain}"

  issuer_url    = "${local.authentik_url}/application/o/vault/"
  client_id     = dependency.authentik_oauth_apps.outputs.apps["vault"].client_id
  client_secret = dependency.authentik_oauth_apps.outputs.client_secrets["vault"]

  allowed_redirect_uris = [
    "https://vault.${include.root.locals.domain}/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vault_oidc_auth" {
  config_path = "../vault-oidc-auth"

  mock_outputs = {
    auth_backend_path = "oidc"
  }
}

terraform {
  # source = "git::https://github.com/itruslan/terraform-modules.git//vault-user-policies?ref=main"
  source = "/Users/rgadzhiev/GitHub/terraform-modules/vault-user-policies"
}

inputs = {
  vault_address = "https://vault.${include.root.locals.domain}"
  auth_path     = dependency.vault_oidc_auth.outputs.auth_backend_path
  policies_dir  = "${get_original_terragrunt_dir()}/policies"
}

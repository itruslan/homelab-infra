include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//authentik-oauth-apps?ref=main"
}

inputs = {
  vault_address    = "https://vault.${include.root.locals.domain}"
  vault_mount_path = "secret"
  vault_enabled    = true
  authentik_url    = "https://auth.${include.root.locals.domain}"

  apps = {
    argocd = {
      name = "ArgoCD"
      allowed_redirect_uris = [
        "https://argocd.${include.root.locals.domain}/auth/callback"
      ]
      vault_secret_path = "authentik/apps/argocd"
    }
    vault = {
      name = "Vault"
      allowed_redirect_uris = [
        "https://vault.${include.root.locals.domain}/ui/vault/auth/oidc/oidc/callback",
        "http://localhost:8250/oidc/callback"
      ]
      vault_secret_path = "authentik/apps/vault"
    }
    grafana = {
      name = "Grafana"
      allowed_redirect_uris = [
        "https://grafana.${include.root.locals.domain}/login/generic_oauth"
      ]
      vault_secret_path = "authentik/apps/grafana"
    }
    proxmox = {
      name = "Proxmox"
      allowed_redirect_uris = [
        "https://pve.${include.root.locals.domain}",
        "https://pve.${include.root.locals.domain}/",
        "https://pve.${include.root.locals.domain}:8006",
        "https://pve.${include.root.locals.domain}:8006/",
        "https://pve-1.${include.root.locals.domain}",
        "https://pve-1.${include.root.locals.domain}/",
        "https://pve-1.${include.root.locals.domain}:8006",
        "https://pve-1.${include.root.locals.domain}:8006/",
        "https://pve-2.${include.root.locals.domain}",
        "https://pve-2.${include.root.locals.domain}/",
        "https://pve-2.${include.root.locals.domain}:8006",
        "https://pve-2.${include.root.locals.domain}:8006/",
        "https://pve-3.${include.root.locals.domain}",
        "https://pve-3.${include.root.locals.domain}/",
        "https://pve-3.${include.root.locals.domain}:8006",
        "https://pve-3.${include.root.locals.domain}:8006/",
      ]
      vault_secret_path = "authentik/apps/proxmox"
    }
    rundeck = {
      name = "Rundeck"
      allowed_redirect_uris = [
        "https://rundeck.${include.root.locals.domain}/oauth2/callback"
      ]
      vault_secret_path = "authentik/apps/rundeck"
    }
  }
}

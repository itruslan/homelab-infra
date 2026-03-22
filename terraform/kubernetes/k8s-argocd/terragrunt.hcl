include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::https://github.com/itruslan/terraform-modules.git//k8s-argocd?ref=main"
}

inputs = {
  kubeconfig_path    = "~/.kube/homelab.yaml"
  kubeconfig_context = "kubernetes-admin@homelab"
  chart_version      = "9.4.14"
  values = [
    file("values.yaml"),
    yamlencode({
      global = { domain = "argocd.${include.root.locals.domain}" }
    })
  ]
  app_projects = [
    { name = "infra", description = "Infrastructure applications" }
  ]
  root_app = {
    repo_url       = "https://github.com/itruslan/homelab-gitops.git"
    bootstrap_path = "bootstrap"
  }
}

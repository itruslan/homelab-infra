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
      "argo-cd" = {
        global = { domain = "argocd.${include.root.locals.domain}" }
      }
    })
  ]
}

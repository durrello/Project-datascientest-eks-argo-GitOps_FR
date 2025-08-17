resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "6.9.0"
  create_namespace = true

  values = [
    templatefile("${path.module}/template/values.yaml", {
      argocd_server_host                     = var.argocd_server_host
      argocd_ingress_enabled                 = var.argocd_ingress_enabled
      argocd_ingress_tls_acme_enabled        = var.argocd_ingress_tls_acme_enabled
      argocd_ingress_ssl_passthrough_enabled = var.argocd_ingress_ssl_passthrough_enabled
      argocd_ingress_class                   = var.argocd_ingress_class
      profile                                = var.profile
    }),
    templatefile("${path.module}/template/repository_values.yaml", {
      "fall-project_repo_secret_key" = var.fall-project_repo_secret_key
      "fall-project_repo"            = var.fall-project_repo
    })
  ]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }
}

module "cert_manager" {
  source                                 = "terraform-iaac/cert-manager/kubernetes"
  version                                = "2.6.3"
  cluster_issuer_email                   = "olivier.rey@gmail.com"
  cluster_issuer_name                    = "letsencrypt-${var.profile}"
  cluster_issuer_private_key_secret_name = "letsencrypt-${var.profile}"
  #   cluster_issuer_server                  = "https://acme-staging-v02.api.letsencrypt.org/directory"
  cluster_issuer_server = "https://acme-v02.api.letsencrypt.org/directory"
  namespace_name        = var.cert_manager_namespace
  create_namespace      = true

  solvers = [
    {
      http01 = {
        ingress = {
          class = "nginx"
        }
      }
    }
  ]
}


module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"
  version = "2.2.0"
  additional_set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
      value = "true"
      type  = "string"
    }
  ]
}

resource "kubernetes_ingress_v1" "fall-project-ingress" {

  wait_for_load_balancer = true
  metadata {
    name      = "${var.namespace}-ingress"
    namespace = var.namespace
    annotations = {
      "cert-manager.io/cluster-issuer"  = "letsencrypt-${var.profile}"
      "kubernetes.io/tls-acme"          = "true"
      "nginx.org/client-max-body-size"  = "10m"
      "nginx.org/proxy-connect-timeout" = "75s"
      "nginx.org/proxy-read-timeout"    = "300s"
      # "nginx.org/redirect-to-https"    = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts = [
        "fall-project.${var.root_domain_name}"
      ]
      secret_name = "${var.namespace}-tls-secret"
    }

    rule {
      host = "fall-project.${var.root_domain_name}"

      http {
        path {
          path      = "/()(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.namespace}-frontend-service"
              port {
                number = var.fall-project_frontend_port
              }
            }
          }
        }

        path {
          path      = "/server(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.namespace}-server-service"
              port {
                number = var.fall-project_server_port
              }
            }
          }
        }
      }
    }
  }
}

module "aws_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  # version = "4.1.1"
  bucket  = var.bucket_name
  acl     = "private"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_policy = false
  attach_deny_insecure_transport_policy = false

  versioning = {
    enabled = true
  }
}

module "velero" {
  source  = "terraform-module/velero/kubernetes"
  version = "1.2.1"

  namespace_deploy            = true
  app_deploy                  = true
  cluster_name                = var.cluster_name
  openid_connect_provider_uri = local.openid_connect_provider_uri
  bucket                      = var.bucket_name
  values = [
    templatefile("${path.module}/template/values.yaml", {
      bucket_name = var.bucket_name
      velero_provider = var.velero_provider
      region = var.region
    })
  ]
}

locals {
  openid_connect_provider_uri = replace(var.cluster_oidc_issuer_url, "https://", "")
}

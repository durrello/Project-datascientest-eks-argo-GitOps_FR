module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name               = var.cluster_name
  cluster_version = "1.30"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks_secrets.arn
    resources        = ["secrets"]
  } 
 
  create = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = var.vpc.vpc_id
  subnet_ids = var.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "${var.ami_type}"
    instance_types = ["${var.instance_type}"]
    sg_private_ids = ["${var.sg_private_id}"]
  }

  eks_managed_node_groups = {
    fall-project = {
      min_size     = 1
      max_size     = 3
      desired_size = "${var.instance_number}"

      instance_types = ["${var.instance_type}"]
      capacity_type  = "SPOT"
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    env       = var.profile
    terraform = "true"
    type      = "end-end-gitops"
  }
  depends_on = [ aws_kms_key.eks_secrets ]
}

# module "aws_auth" {
#   source = "terraform-aws-modules/eks/aws//modules/aws-auth"
#   manage_aws_auth_configmap = true
#   aws_auth_roles = [
#     {
#       rolearn  = var.eks_admins_iam_role.iam_role_arn
#       username = var.eks_admins_iam_role.iam_role_name
#       groups   = ["system:masters"]
#     },
#   ]
# }

resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = data.aws_availability_zones.available.names
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = var.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  node_groups = var.node_groups

  tags = var.common_tags

  depends_on = [module.vpc]
}

# Configure providers for Helm module
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

# Helm Charts Module
module "helm_charts" {
  source = "./modules/helm"

  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_cert  = module.eks.cluster_certificate_authority_data
  cluster_name     = var.cluster_name

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  GITLAB_USERNAME              = var.GITLAB_USERNAME
  GITLAB_PERSONAL_ACCESS_TOKEN = var.GITLAB_PERSONAL_ACCESS_TOKEN
  GITLAB_REPO_URL              = var.GITLAB_REPO_URL
  GITLAB_REPO_BRANCH           = var.GITLAB_REPO_BRANCH
  GITLAB_REPO_PATH             = var.GITLAB_REPO_PATH
  APP_NAMESPACE                = var.APP_NAMESPACE

  depends_on = [module.eks]
}

# SonarQube EC2 Module
module "sonarqube" {
  source = "./modules/sonarqube"

  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnet_ids[0]
  instance_type     = var.sonarqube_instance_type
  security_group_id = module.vpc.sonarqube_sg_id
  depends_on        = [module.vpc]
}   
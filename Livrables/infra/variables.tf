# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "eks-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_groups" {
  description = "EKS node group configurations"
  type = map(object({
    instance_types = list(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    disk_size     = number
    ami_type      = string
    capacity_type = string
  }))
  default = {
    main = {
      instance_types = ["t3.medium"]
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 1
      }
      disk_size     = 50
      ami_type      = "AL2_x86_64"
      capacity_type = "ON_DEMAND"
    }
  }
}

variable "sonarqube_instance_type" {
  description = "Instance type for SonarQube EC2"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SonarQube instance"
  type        = string
}

variable "sonarqube_allowed_cidrs" {
  description = "CIDR blocks allowed to access SonarQube"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "eks-infrastructure"
    ManagedBy   = "terraform"
  }
}


# variable "GITLAB_USERNAME" {
#   description = "GitLab username for ArgoCD access"
#   type        = string
# }

# variable "GITLAB_PERSONAL_ACCESS_TOKEN" {
#   description = "GitLab personal access token for ArgoCD access"
#   type        = string
#   sensitive   = true
# }

# variable "GITLAB_REPO_URL" {
#   description = "GitLab repository URL for ArgoCD"
#   type        = string
# }

# variable "GITLAB_REPO_BRANCH" {
#   description = "GitLab repository branch for ArgoCD"
#   type        = string
#   default     = "master"
# }

# variable "GITLAB_REPO_PATH" {
#   description = "Path within the GitLab repository for ArgoCD"
#   type        = string
#   default     = "."
# }

# variable "APP_NAMESPACE" {
#   description = "Kubernetes namespace where the application will be deployed"
#   type        = string
#   default     = "default"
# }

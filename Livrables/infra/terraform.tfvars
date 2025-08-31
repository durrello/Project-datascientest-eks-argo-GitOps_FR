# terraform.tfvars.example
aws_region = "us-east-1"
vpc_name   = "my-eks-vpc"
vpc_cidr   = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

cluster_name    = "my-eks-cluster"
cluster_version = "1.28"

node_groups = {
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

sonarqube_instance_type = "t3.medium"
key_pair_name           = "test" 
sonarqube_allowed_cidrs = ["0.0.0.0/0"] 

common_tags = {
  Environment = "development"
  Project     = "eks-infrastructure"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
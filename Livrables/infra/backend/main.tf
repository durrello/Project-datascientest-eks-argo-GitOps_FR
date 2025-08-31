# Livrables/backend/main.tf
# This creates the S3 bucket and DynamoDB table for Terraform state management

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "shared"
      ManagedBy   = "terraform"
      Purpose     = "backend-infrastructure"
    }
  }
}

# Generate a unique suffix for the bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for storing Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${var.project_name}-terraform-state-${random_string.bucket_suffix.result}"
  force_destroy = false

  tags = {
    Name        = "Terraform State Bucket"
    Description = "Stores Terraform state files for ${var.project_name}"
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add lifecycle configuration to manage old versions
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "terraform_state_lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  
  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Description = "Handles state locking for ${var.project_name} Terraform operations"
  }
}

# Output values for use in main infrastructure
output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "Name of the S3 bucket for Terraform state"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "ARN of the S3 bucket for Terraform state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "Name of the DynamoDB table for Terraform locks"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.terraform_locks.arn
  description = "ARN of the DynamoDB table for Terraform locks"
}

output "setup_complete_message" {
  value       = <<-EOT
    
    Backend infrastructure setup complete!
    
    S3 Bucket: ${aws_s3_bucket.terraform_state.bucket}
    DynamoDB Table: ${aws_dynamodb_table.terraform_locks.name}
    Region: ${var.aws_region}
    
    This backend is now ready to store Terraform state for your infrastructure.
  EOT
  description = "Setup completion message with details"
}

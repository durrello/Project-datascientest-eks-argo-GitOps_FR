# Livrables/backend/variables.tf
# Variables for backend infrastructure setup

variable "project_name" {
  description = "Name of the project (used for naming resources)"
  type        = string
  default     = "reddit-clone"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must only contain lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.aws_region)
    error_message = "Please specify a valid AWS region."
  }
}

variable "environment" {
  description = "Environment name (shared for backend resources)"
  type        = string
  default     = "shared"
}
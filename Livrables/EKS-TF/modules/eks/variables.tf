variable "namespace" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "ami_type" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_number" {
  type = number
}

variable "profile" {
  type = string
}

variable "vpc" {
  type = any
}

variable "private_subnets" {
  type = any
}

variable "sg_private_id" {
  type = any
}

variable "eks_admins_iam_role" {
  type = any
}

variable "create" {
  description = "Controls if EKS resources should be created"
  type        = bool
  default     = true
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "890742601171"
}

variable "partition" {
  description = "AWS partition (e.g., aws, aws-cn, aws-us-gov)"
  type        = string
  default     = "aws"
}

locals {
  partition  = var.partition != "" ? var.partition : var.partition
  account_id = var.account_id != "" ? var.account_id : var.account_id
}

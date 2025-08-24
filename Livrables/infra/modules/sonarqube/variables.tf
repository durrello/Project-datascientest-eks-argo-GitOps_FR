# modules/sonarqube/variables.tf
variable "vpc_id" {
  description = "VPC ID where SonarQube will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for SonarQube instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for SonarQube"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access SonarQube"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
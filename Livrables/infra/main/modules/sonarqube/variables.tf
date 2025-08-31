variable "ami" {
  description = "ami"
  default     = "ami-0bbdd8c17ed981ef9"
}

variable "instance_type" {
  description = "instance_type"
  default     = "t3.medium"
}

variable "port" {
  description = "port"
  default     = 9000
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "security_group_id" {
  type = string
}

variable "subnet_id" {

}
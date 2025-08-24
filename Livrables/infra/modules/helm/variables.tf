# modules/helm/variables.tf
variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_cert" {
  description = "EKS cluster certificate authority data"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "GITLAB_USERNAME" {
  description = "GitLab username for ArgoCD access"
  type        = string
}

variable "GITLAB_PERSONAL_ACCESS_TOKEN" {
  description = "GitLab personal access token for ArgoCD access"
  type        = string
  sensitive   = true
}

variable "GITLAB_REPO_URL" {
  description = "GitLab repository URL for ArgoCD"
  type        = string
}

variable "GITLAB_REPO_BRANCH" {
  description = "GitLab repository branch for ArgoCD"
  type        = string
  default     = "master"
}

variable "GITLAB_REPO_PATH" {
  description = "Path within the GitLab repository for ArgoCD"
  type        = string
  default     = "."
}

variable "APP_NAMESPACE" {
  description = "Kubernetes namespace where the application will be deployed"
  type        = string
  default     = "default"
}
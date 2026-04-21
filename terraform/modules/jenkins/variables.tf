variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_host" {
  description = "EKS API server endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Decoded cluster CA certificate"
  type        = string
  sensitive   = true
}

variable "cluster_token" {
  description = "Authentication token for the Kubernetes API"
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Namespace where Jenkins will be installed"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Version of the Jenkins Helm chart"
  type        = string
  default     = "5.8.58"
}

variable "admin_username" {
  description = "Jenkins administrator username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Jenkins administrator password"
  type        = string
  sensitive   = true
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN for Jenkins agent push permissions"
  type        = string
}

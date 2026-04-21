variable "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN used by the Jenkins agent"
  type        = string
}

variable "iam_role_name" {
  description = "IAM role name for the Jenkins agent"
  type        = string
}

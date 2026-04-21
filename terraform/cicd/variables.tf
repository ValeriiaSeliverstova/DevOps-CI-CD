variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Existing EKS cluster name"
  type        = string
  default     = "goit-eks"
}

variable "ecr_repository_name" {
  description = "Existing ECR repository name"
  type        = string
  default     = "goit-ecr"
}

variable "jenkins_namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "jenkins_admin_username" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "jenkins_chart_version" {
  description = "Version of the Jenkins Helm chart"
  type        = string
  default     = "5.8.58"
}

variable "argocd_chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "7.7.16"
}

variable "argocd_applications_chart_version" {
  description = "Version of the local Helm chart used to create Argo CD applications and repositories"
  type        = string
  default     = "0.1.0"
}

variable "argocd_repo_url" {
  description = "Git repository URL watched by Argo CD"
  type        = string
}

variable "argocd_repo_path" {
  description = "Path to the Helm chart or manifests inside the GitOps repository"
  type        = string
  default     = "helm/django-chart"
}

variable "argocd_target_revision" {
  description = "Git revision watched by Argo CD"
  type        = string
  default     = "main"
}

variable "argocd_destination_namespace" {
  description = "Namespace where the Django application will be deployed by Argo CD"
  type        = string
  default     = "django-app"
}

variable "argocd_application_name" {
  description = "Name of the Argo CD Application resource"
  type        = string
  default     = "django-app"
}

variable "argocd_repositories" {
  description = "Additional repositories registered in Argo CD"
  type = list(object({
    name     = string
    url      = string
    type     = optional(string, "git")
    username = optional(string)
    password = optional(string)
    ssh_key  = optional(string)
  }))
  default = []
}

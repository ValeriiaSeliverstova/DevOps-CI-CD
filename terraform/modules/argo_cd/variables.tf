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
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "7.7.16"
}

variable "applications_chart_version" {
  description = "Version of the local Helm chart that creates Argo CD apps and repositories"
  type        = string
  default     = "0.1.0"
}

variable "application_name" {
  description = "Name of the main Argo CD Application"
  type        = string
  default     = "django-app"
}

variable "repo_url" {
  description = "Git repository URL watched by Argo CD"
  type        = string
}

variable "repo_path" {
  description = "Path to the Helm chart or manifests inside the GitOps repository"
  type        = string
  default     = "helm/django-chart"
}

variable "target_revision" {
  description = "Git revision watched by Argo CD"
  type        = string
  default     = "main"
}

variable "destination_namespace" {
  description = "Namespace where the application will be deployed by Argo CD"
  type        = string
  default     = "django-app"
}

variable "repositories" {
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

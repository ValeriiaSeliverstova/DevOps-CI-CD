variable "cluster_host" {
  description = "EKS cluster API server endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Decoded cluster CA certificate"
  type        = string
}

variable "cluster_token" {
  description = "Authentication token for the cluster"
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  description = "Optional version of the Prometheus Helm chart. Leave empty to use the latest chart from the repo."
  type        = string
  default     = ""
}

variable "grafana_chart_version" {
  description = "Optional version of the Grafana Helm chart. Leave empty to use the latest chart from the repo."
  type        = string
  default     = ""
}

variable "grafana_admin_username" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "change-me-grafana"
}

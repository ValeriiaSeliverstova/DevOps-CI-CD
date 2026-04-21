output "namespace" {
  description = "Namespace where Argo CD is installed"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "server_url" {
  description = "Internal Argo CD server URL"
  value       = "http://argocd-server.${kubernetes_namespace.this.metadata[0].name}.svc.cluster.local"
}

output "initial_admin_password" {
  description = "Initial Argo CD admin password"
  value       = data.kubernetes_secret_v1.initial_admin.data.password
  sensitive   = true
}

output "application_name" {
  description = "Default Argo CD application managed by the bootstrap chart"
  value       = var.application_name
}

output "namespace" {
  description = "Namespace where Jenkins is installed"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "service_name" {
  description = "Jenkins Kubernetes service name"
  value       = data.kubernetes_service.jenkins.metadata[0].name
}

output "service_url" {
  description = "Internal Jenkins service URL"
  value       = "http://${data.kubernetes_service.jenkins.metadata[0].name}.${kubernetes_namespace.this.metadata[0].name}.svc.cluster.local:8080"
}

output "admin_username" {
  description = "Jenkins admin username"
  value       = var.admin_username
}

output "admin_password" {
  description = "Jenkins admin password"
  value       = var.admin_password
  sensitive   = true
}

output "agent_role_arn" {
  description = "IAM role ARN attached to the Jenkins Kubernetes agent"
  value       = module.irsa.role_arn
}

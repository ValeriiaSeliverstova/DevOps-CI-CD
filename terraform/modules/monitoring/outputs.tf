output "namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_url" {
  value = local.prometheus_server_url
}

output "grafana_url" {
  value = "http://${local.grafana_release_name}.${var.namespace}.svc.cluster.local"
}

output "grafana_admin_username" {
  value = var.grafana_admin_username
}

output "grafana_admin_password" {
  value     = var.grafana_admin_password
  sensitive = true
}

locals {
  prometheus_release_name = "prometheus"
  grafana_release_name    = "grafana"
  prometheus_server_url   = "http://${local.prometheus_release_name}-server.${var.namespace}.svc.cluster.local"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "prometheus" {
  name             = local.prometheus_release_name
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  version          = var.prometheus_chart_version != "" ? var.prometheus_chart_version : null
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 900

  values = [
    yamlencode({
      alertmanager = {
        enabled = false
      }
      pushgateway = {
        enabled = false
      }
      server = {
        persistentVolume = {
          enabled = false
        }
        service = {
          type = "ClusterIP"
        }
        resources = {
          requests = {
            cpu    = "150m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "768Mi"
          }
        }
      }
    })
  ]
}

resource "helm_release" "grafana" {
  name             = local.grafana_release_name
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = var.grafana_chart_version != "" ? var.grafana_chart_version : null
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 900

  values = [
    yamlencode({
      persistence = {
        enabled = false
      }
      service = {
        type = "ClusterIP"
      }
      testFramework = {
        enabled = false
      }
      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "300m"
          memory = "512Mi"
        }
      }
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              url       = local.prometheus_server_url
              access    = "proxy"
              isDefault = true
            }
          ]
        }
      }
    })
  ]

  set {
    name  = "adminUser"
    value = var.grafana_admin_username
  }

  set_sensitive {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  depends_on = [
    helm_release.prometheus,
  ]
}

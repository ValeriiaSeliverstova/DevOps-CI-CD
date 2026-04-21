locals {
  applications = [
    {
      name                  = var.application_name
      namespace             = var.namespace
      project               = "default"
      repo_url              = var.repo_url
      path                  = var.repo_path
      target_revision       = var.target_revision
      destination_server    = "https://kubernetes.default.svc"
      destination_namespace = var.destination_namespace
      create_namespace      = true
      automated             = true
      prune                 = true
      self_heal             = true
    }
  ]
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = kubernetes_namespace.this.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 900

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "applications" {
  name      = "argocd-applications"
  chart     = "${path.module}/charts"
  namespace = kubernetes_namespace.this.metadata[0].name
  wait      = true
  timeout   = 300

  values = [
    yamlencode({
      applications = local.applications
      repositories = var.repositories
    })
  ]

  depends_on = [
    helm_release.this,
  ]
}

data "kubernetes_secret_v1" "initial_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  depends_on = [helm_release.this]
}

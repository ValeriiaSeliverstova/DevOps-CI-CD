module "irsa" {
  source = "../ci-iam"

  cluster_oidc_issuer_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  namespace               = var.namespace
  service_account_name    = "jenkins-agent"
  ecr_repository_arn      = var.ecr_repository_arn
  iam_role_name           = "${var.cluster_name}-jenkins-agent"
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "agent" {
  metadata {
    name      = "jenkins-agent"
    namespace = kubernetes_namespace.this.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa.role_arn
    }
  }
}

resource "helm_release" "this" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = var.chart_version
  namespace        = kubernetes_namespace.this.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 900

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "controller.admin.username"
    value = var.admin_username
  }

  set_sensitive {
    name  = "controller.admin.password"
    value = var.admin_password
  }

  set {
    name  = "agent.namespace"
    value = var.namespace
  }

  set {
    name  = "agent.serviceAccount"
    value = kubernetes_service_account.agent.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.agent,
  ]
}

data "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  depends_on = [helm_release.this]
}

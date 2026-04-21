provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_ecr_repository" "this" {
  name = var.ecr_repository_name
}

module "jenkins" {
  source = "../modules/jenkins"

  cluster_name           = data.aws_eks_cluster.this.name
  cluster_host           = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  cluster_token          = data.aws_eks_cluster_auth.this.token

  namespace          = var.jenkins_namespace
  admin_username     = var.jenkins_admin_username
  admin_password     = var.jenkins_admin_password
  chart_version      = var.jenkins_chart_version
  ecr_repository_arn = data.aws_ecr_repository.this.arn
}

module "argo_cd" {
  source = "../modules/argo_cd"

  cluster_host           = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  cluster_token          = data.aws_eks_cluster_auth.this.token

  namespace                  = var.argocd_namespace
  chart_version              = var.argocd_chart_version
  applications_chart_version = var.argocd_applications_chart_version
  repo_url                   = var.argocd_repo_url
  repo_path                  = var.argocd_repo_path
  target_revision            = var.argocd_target_revision
  destination_namespace      = var.argocd_destination_namespace
  application_name           = var.argocd_application_name
  repositories               = var.argocd_repositories
}

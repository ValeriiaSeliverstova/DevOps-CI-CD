terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_host
    cluster_ca_certificate = var.cluster_ca_certificate
    token                  = var.cluster_token
  }
}

provider "kubernetes" {
  host                   = var.cluster_host
  cluster_ca_certificate = var.cluster_ca_certificate
  token                  = var.cluster_token
}

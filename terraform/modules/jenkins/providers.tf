terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    helm = {
      source = "hashicorp/helm"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    tls = {
      source = "hashicorp/tls"
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

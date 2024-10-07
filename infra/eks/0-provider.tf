# Specify required providers and their versions for the Terraform configuration
terraform {
  required_providers {
    # Helm provider for managing Helm charts
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "2.12.1"
    # }

    # Kubectl provider for interacting with Kubernetes clusters
    # kubectl = {
    #   source  = "gavinbunney/kubectl"
    #   version = "1.14.0"
    # }
  }

  # Specify the required Terraform version
  required_version = "~> 1.0"
}

# Define the AWS provider configuration for the us-east-1 region
provider "aws" {
  region = var.region
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

// Authenticating Helm to kubernetes cluster
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

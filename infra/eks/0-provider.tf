# Provider Configuration File
# ===========================

# Specify the required providers and Terraform version
terraform {
  required_version = "~> 1.0"
}

# AWS Provider Configuration
# ---------------------------
# This defines the AWS provider and sets the region based on the `region` variable.
provider "aws" {
  region = var.region
}

# EKS Cluster Authentication
# ---------------------------
# Fetches authentication details for connecting to the EKS cluster.
data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

# Kubernetes Provider Configuration
# ----------------------------------
# Configures the Kubernetes provider to interact with the EKS cluster.
provider "kubernetes" {
  # API server endpoint of the EKS cluster
  host = module.eks.cluster_endpoint

  # Authentication token for accessing the Kubernetes API
  token = data.aws_eks_cluster_auth.eks.token

  # Base64-decoded cluster CA certificate for secure communication
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

# Helm Provider Configuration
# ----------------------------
# Configures the Helm provider to manage Helm charts in the EKS cluster.
provider "helm" {
  kubernetes {
    # API server endpoint of the EKS cluster
    host = module.eks.cluster_endpoint

    # Authentication token for accessing the Kubernetes API
    token = data.aws_eks_cluster_auth.eks.token

    # Base64-decoded cluster CA certificate for secure communication
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

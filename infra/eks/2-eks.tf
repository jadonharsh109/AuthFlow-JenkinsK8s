resource "aws_iam_policy" "eks_node_ebs_policy" {
  name        = "EKSNodeEBSPolicy"
  description = "Allows EKS nodes to perform necessary EBS operations"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeVolumes",
          "ec2:CreateTags",
          "ec2:DescribeTags"
        ],
        "Resource" : "*"
      }
    ]
  })
}


# Module for creating an Amazon EKS (Elastic Kubernetes Service) cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  # EKS cluster name
  cluster_name = var.eks_cluster_name

  # EKS cluster version
  cluster_version = var.eks_cluster_version

  # Enable or disable public and private access to the EKS cluster endpoint
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # VPC and subnet configurations
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cloudwatch_log_group = true

  # Enable IAM Roles for Service Accounts (IRSA)
  enable_irsa = true

  # Default configuration for managed node groups
  eks_managed_node_group_defaults = {
    disk_size = 30
  }

  # Configuration for managed node groups within the EKS cluster
  eks_managed_node_groups = {
    # General node group configuration
    general = {
      desired_size = 3
      min_size     = 3
      max_size     = 5

      # EC2 instance types and capacity type for the node group
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      iam_role_additional_policies = {
        "custom_policy" = aws_iam_policy.eks_node_ebs_policy.arn
      }

    }

    # Spot instance node group configuration
    spot = {
      desired_size = 2
      min_size     = 2
      max_size     = 5

      # Labels and taints for identifying and managing spot instances
      labels = {
        role = "spot"
      }
      iam_role_additional_policies = {
        "custom_policy" = aws_iam_policy.eks_node_ebs_policy.arn
      }


      # EC2 instance types and capacity type for the spot instance node group
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }

  # Tags to apply to AWS resources created by the EKS module
  tags = {
    Environment = "Production"
  }

}

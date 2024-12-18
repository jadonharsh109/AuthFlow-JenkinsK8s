# IAM Policy for EKS Nodes to Manage EBS
# --------------------------------------
resource "aws_iam_policy" "eks_node_ebs_policy" {
  name        = "EKSNodeEBSPolicy"
  description = "Allows EKS nodes to perform necessary EBS operations"

  # Policy document defining permissions for EKS nodes
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

# EKS Cluster Module Configuration
# --------------------------------
module "eks" {
  # Source and version of the EKS module from Terraform Registry
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  # General Cluster Settings
  # ------------------------
  # Name and Kubernetes version of the EKS cluster
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  # VPC and Subnet Configuration
  # ----------------------------
  # Attach the EKS cluster to the VPC created in the VPC module
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Enable private and public access to the cluster API endpoint
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Logging Configuration
  # ----------------------
  # Automatically create a CloudWatch log group for the cluster
  create_cloudwatch_log_group = true

  # IAM and Security Settings
  # -------------------------
  # Enable IAM Roles for Service Accounts (IRSA) for fine-grained pod-level access
  enable_irsa = true

  # Managed Node Group Defaults
  # ---------------------------
  # Set default disk size for EKS-managed node groups
  eks_managed_node_group_defaults = {
    disk_size = 30
  }

  # Managed Node Groups Configuration
  # ----------------------------------
  eks_managed_node_groups = {
    # General purpose node group (On-Demand instances)
    general = {
      desired_size = 3
      min_size     = 3
      max_size     = 5

      # Instance types and capacity type (On-Demand)
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      # Attach custom IAM policy for managing EBS
      iam_role_additional_policies = {
        "custom_policy" = aws_iam_policy.eks_node_ebs_policy.arn
      }
    }

    # Spot instance node group (for cost optimization)
    spot = {
      desired_size = 2
      min_size     = 2
      max_size     = 5

      # Labels for identifying spot instance nodes
      labels = {
        role = "spot"
      }

      # Instance types and capacity type (Spot)
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      # Attach custom IAM policy for managing EBS
      iam_role_additional_policies = {
        "custom_policy" = aws_iam_policy.eks_node_ebs_policy.arn
      }
    }
  }

  # Tags
  # ----
  # Apply common tags to all resources created by this module
  tags = {
    Environment = "Production"
  }
}

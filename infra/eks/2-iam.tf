# Create IAM Group for Read-Only Access to EKS
resource "aws_iam_group" "eks_ro" {
  name = "${var.eks_cluster_name}-eks-ro"
}

# Create IAM Group for Full Control Access to EKS
resource "aws_iam_group" "eks_full_control" {
  name = "${var.eks_cluster_name}-eks-full-control"
}

# Optional: Attach policies to the IAM Groups

# Create a Policy for Read-Only Access to EKS
resource "aws_iam_policy" "eks_ro_policy" {
  name        = "${var.eks_cluster_name}-eks-ro-policy"
  description = "Policy to grant read-only access to EKS resources"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Attach Read-Only Policy to the eks-ro Group
resource "aws_iam_group_policy_attachment" "eks_ro_policy_attachment" {
  group      = aws_iam_group.eks_ro.name
  policy_arn = aws_iam_policy.eks_ro_policy.arn
}

# Create a Policy for Full Control Access to EKS
resource "aws_iam_policy" "eks_full_control_policy" {
  name        = "${var.eks_cluster_name}-eks-full-control-policy"
  description = "Policy to grant full control access to EKS resources"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "eks:*",
          "ec2:*",
          "logs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Attach Full Control Policy to the eks-full-control Group
resource "aws_iam_group_policy_attachment" "eks_full_control_policy_attachment" {
  group      = aws_iam_group.eks_full_control.name
  policy_arn = aws_iam_policy.eks_full_control_policy.arn
}

# Optional: Add Users to the Groups (Adjust as needed)

# Create an example IAM User and add to eks-ro group
resource "aws_iam_user" "example_user_ro" {
  name = "${var.eks_cluster_name}-example-ro-user"
}

resource "aws_iam_user_group_membership" "example_user_ro_membership" {
  user = aws_iam_user.example_user_ro.name
  groups = [
    aws_iam_group.eks_ro.name
  ]
}

# Create an example IAM User and add to eks-full-control group
resource "aws_iam_user" "example_user_full_control" {
  name = "${var.eks_cluster_name}-example-full-control-user"
}

resource "aws_iam_user_group_membership" "example_user_full_control_membership" {
  user = aws_iam_user.example_user_full_control.name
  groups = [
    aws_iam_group.eks_full_control.name
  ]
}

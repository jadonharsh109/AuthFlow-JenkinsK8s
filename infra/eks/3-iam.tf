# Get AWS Account ID dynamically
data "aws_caller_identity" "current" {}

# Trust policy for assuming roles 
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:default"]
    }
  }

  # Trust policy allowing AWS account to assume the role
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# IAM Role for Read-Only Access
resource "aws_iam_role" "read_only_role" {
  name = "ReadOnlyAccessRole"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

# IAM Role for Full Access
resource "aws_iam_role" "full_access_role" {
  name = "FullAccessRole"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}


# IAM Group for Read-Only Access
resource "aws_iam_group" "read_only_group" {
  name = "${var.eks_cluster_name}-ReadOnlyAccessGroup"
}

# IAM Group Policy Attachment for Read-Only Access
resource "aws_iam_group_policy_attachment" "read_only_policy_attachment" {
  group      = aws_iam_group.read_only_group.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# IAM Group Policy for assuming Read-Only Role
resource "aws_iam_group_policy" "read_only_assume_role_policy" {
  group = aws_iam_group.read_only_group.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.read_only_role.name}"
      }
    ]
  })
}

# IAM Group for Full Access
resource "aws_iam_group" "full_access_group" {
  name = "${var.eks_cluster_name}-FullAccessGroup"
}

# IAM Group Policy Attachment for Full Access
resource "aws_iam_group_policy_attachment" "full_access_policy_attachment" {
  group      = aws_iam_group.full_access_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# IAM Group Policy for assuming Full Access Role
resource "aws_iam_group_policy" "full_access_assume_role_policy" {
  group = aws_iam_group.full_access_group.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Resource" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.full_access_role.name}"
      }
    ]
  })
}

# Create Test User 1
resource "aws_iam_user" "test_user1" {
  name = "readonly-user"
}

# Add Test User 1 to Read-Only Group
resource "aws_iam_user_group_membership" "test_user1_membership" {
  user   = aws_iam_user.test_user1.name
  groups = [aws_iam_group.read_only_group.name]
}

# Create Access Keys for Test User 1
resource "aws_iam_access_key" "readonly_user_access_key" {
  user = aws_iam_user.test_user1.name
}

# Create Test User 2
resource "aws_iam_user" "test_user2" {
  name = "fullaccess-user"
}

# Add Test User 2 to Full Access Group
resource "aws_iam_user_group_membership" "test_user2_membership" {
  user   = aws_iam_user.test_user2.name
  groups = [aws_iam_group.full_access_group.name]
}

# Create Access Keys for Test User 2
resource "aws_iam_access_key" "fullaccess_user_access_key" {
  user = aws_iam_user.test_user2.name
}

# Define IAM policy document for NGINX ingress controller to assume role via OIDC
data "aws_iam_policy_document" "eks_assume_nginx_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:nginx-ingress-controller-sa"]
    }
  }
}

# IAM Role for NGINX ingress controller
resource "aws_iam_role" "nginx_ingress_role" {
  name               = "nginx-ingress-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_nginx_role_policy.json
}

# IAM Policy for NGINX ingress controller
resource "aws_iam_policy" "nginx_ingress_policy" {
  name        = "nginx-ingress-policy"
  description = "Policy for NGINX Ingress to interact with AWS resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancerAttributes"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the IAM Policy to the NGINX IAM Role
resource "aws_iam_role_policy_attachment" "nginx_ingress_role_policy_attachment" {
  policy_arn = aws_iam_policy.nginx_ingress_policy.arn
  role       = aws_iam_role.nginx_ingress_role.name
}

# Create Kubernetes Service Account for NGINX ingress controller
resource "kubernetes_service_account" "nginx_ingress_controller_sa" {
  metadata {
    name      = "nginx-ingress-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.nginx_ingress_role.arn
    }
  }

  # Ensure the EKS cluster is created before the service account
  depends_on = [module.eks]
}

# Install NGINX ingress controller using Helm
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  # Use pre-existing service account for the ingress controller
  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = kubernetes_service_account.nginx_ingress_controller_sa.metadata[0].name
  }

  depends_on = [kubernetes_service_account.nginx_ingress_controller_sa]
}

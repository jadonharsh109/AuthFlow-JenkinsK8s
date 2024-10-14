data "aws_iam_policy_document" "eks_assume_nginx_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:nginx-ingress-controller-sa"]
    }
  }
}

resource "aws_iam_role" "nginx_ingress_role" {
  name               = "nginx-ingress-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_policy" "nginx_ingress_policy" {
  name        = "nginx-ingress-policy"
  description = "Policy for NGINX Ingress to interact with AWS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancerAttributes"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.nginx_ingress_policy.arn
  role       = aws_iam_role.nginx_ingress_role.name
}

resource "kubernetes_service_account" "nginx_ingress_controller_sa" {
  metadata {
    name      = "nginx-ingress-controller-sa"
    namespace = "kube-system"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "kube-system" # You may choose another namespace if desired
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"


  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "nginx-ingress-controller-sa"
  }
}

# Define IAM policy document for EBS CSI Driver to assume role via OIDC
data "aws_iam_policy_document" "eks_assume_ebs_role_policy" {
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
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  name               = "EBSCSIDriverRole"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_ebs_role_policy.json
}

# IAM Policy for EBS CSI Driver
resource "aws_iam_policy" "ebs_csi_driver_policy" {
  name        = "EBSCSIDriverPolicy"
  description = "Policy for EBS CSI Driver to manage EBS volumes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:CreateTags",
        "ec2:CreateVolume"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach IAM Policy to the EBS CSI Driver Role
resource "aws_iam_role_policy_attachment" "attach_ebs_csi_driver_policy" {
  policy_arn = aws_iam_policy.ebs_csi_driver_policy.arn
  role       = aws_iam_role.ebs_csi_driver.name
}

# Create Kubernetes Service Account for EBS CSI Controller
resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver.arn
    }
  }

  depends_on = [module.eks]
}

# Deploy AWS EBS CSI Driver using Helm
resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = kubernetes_service_account.ebs_csi_controller_sa.metadata[0].name
  }

  set {
    name  = "node.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "node.serviceAccount.name"
    value = kubernetes_service_account.ebs_csi_controller_sa.metadata[0].name
  }

  depends_on = [aws_iam_role.ebs_csi_driver, kubernetes_service_account.ebs_csi_controller_sa]
}

# Define EBS StorageClass for dynamic provisioning of volumes
resource "kubernetes_storage_class" "aws_ebs_csi_storage_class" {
  metadata {
    name = "ebs-storage"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy      = "Delete"

  depends_on = [helm_release.aws_ebs_csi_driver]
}

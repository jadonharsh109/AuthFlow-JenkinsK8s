resource "null_resource" "apply_manifests" {
  provisioner "local-exec" {
    command = "kubectl apply -f k8s/"
    when    = create
  }
  depends_on = [terraform_data.kubeconfig]
}

resource "null_resource" "update_aws_auth" {
  provisioner "local-exec" {
    command = templatefile("${path.module}/update-aws-auth.sh.tpl", {
      readonly_role_arn   = aws_iam_role.read_only_role.arn
      fullaccess_role_arn = aws_iam_role.full_access_role.arn
    })
  }

  # Add a dependency if needed, for example on your EKS cluster creation
  depends_on = [null_resource.apply_manifests]
}


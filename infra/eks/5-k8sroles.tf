# Apply Kubernetes manifests after generating kubeconfig
resource "null_resource" "apply_manifests" {
  provisioner "local-exec" {
    command = "kubectl apply -f eks-auth-yaml/"
  }

  # Ensure kubeconfig is generated before applying manifests
  depends_on = [null_resource.generate_kubeconfig]
}

# Update the AWS Auth ConfigMap to assign IAM roles to Kubernetes groups
resource "null_resource" "update_aws_auth" {
  provisioner "local-exec" {
    # Use the templatefile function to populate the update-aws-auth script
    command = templatefile("${path.module}/update-aws-auth.sh.tpl", {
      readonly_role_arn   = aws_iam_role.read_only_role.arn,
      fullaccess_role_arn = aws_iam_role.full_access_role.arn
    })
  }

  # Ensure Kubernetes manifests are applied before updating the ConfigMap
  depends_on = [null_resource.apply_manifests]
}

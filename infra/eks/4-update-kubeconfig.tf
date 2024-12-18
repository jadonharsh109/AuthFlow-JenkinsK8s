# Generate kubeconfig file for the EKS cluster
resource "null_resource" "generate_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
  }

  # Ensure the EKS cluster is created before running this command
  depends_on = [module.eks]
}

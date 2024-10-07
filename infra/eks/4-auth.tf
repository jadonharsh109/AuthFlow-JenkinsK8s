// Cluster authentication & autherization related information
resource "terraform_data" "kubeconfig" {
  provisioner "local-exec" {
    when    = create
    command = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}" // This will pull the kubeconfig file from aws eks.
  }
  depends_on = [module.eks]
}





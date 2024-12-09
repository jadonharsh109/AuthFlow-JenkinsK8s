# Output a command to update kubeconfig
output "update_kubeconfig_command" {
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
  description = "Run this command in your terminal to update your kubeconfig file with the EKS cluster context."
}

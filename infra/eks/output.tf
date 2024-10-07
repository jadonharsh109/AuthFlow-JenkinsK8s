# Output a command to update kubeconfig
output "update_kubeconfig_command" {
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
  description = "Run this command in your terminal to update your kubeconfig file with the EKS cluster context."
}

# Output Access Keys for Test Users
output "readonly_user_access_key_id" {
  value = aws_iam_access_key.readonly_user_access_key.id
}

output "readonly_user_secret_access_key" {
  value     = aws_iam_access_key.readonly_user_access_key.secret
  sensitive = true
}

output "fullaccess_user_access_key_id" {
  value = aws_iam_access_key.fullaccess_user_access_key.id
}

output "fullaccess_user_secret_access_key" {
  value     = aws_iam_access_key.fullaccess_user_access_key.secret
  sensitive = true
}

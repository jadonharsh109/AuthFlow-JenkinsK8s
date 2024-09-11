data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "null_resource" "create_or_update_configmap" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      set -e
      # Check if the ConfigMap exists
      if kubectl get configmap aws-auth -n kube-system; then
        echo "ConfigMap aws-auth exists, updating it."
        # Update the ConfigMap using the kubectl patch command
        kubectl patch configmap aws-auth -n kube-system --patch "$(cat ${path.module}/aws-auth-patch.yaml)"
      else
        echo "ConfigMap aws-auth does not exist, creating it."
        # Create the ConfigMap using kubectl apply
        kubectl apply -f ${path.module}/aws-auth-config.yaml
      fi
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Create the aws-auth ConfigMap YAML file
data "template_file" "aws_auth_config" {
  template = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.eks.eks_managed_node_groups["general"].iam_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${module.eks.eks_managed_node_groups["spot"].iam_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${aws_iam_group.eks_ro.arn}
      username: eks-read-only
      groups:
        - eks-read-only-group
    - rolearn: ${aws_iam_group.eks_full_control.arn}
      username: eks-full-control
      groups:
        - eks-full-control-group
EOT
}

# Output the ConfigMap content to a file
resource "local_file" "aws_auth_config" {
  content  = data.template_file.aws_auth_config.rendered
  filename = "${path.module}/aws-auth-config.yaml"
}

# Patch file for updates to the existing ConfigMap
data "template_file" "aws_auth_patch" {
  template = <<EOT
data:
  mapRoles: |
    - rolearn: ${module.eks.eks_managed_node_groups["general"].iam_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${module.eks.eks_managed_node_groups["spot"].iam_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${aws_iam_group.eks_ro.arn}
      username: eks-read-only
      groups:
        - eks-read-only-group
    - rolearn: ${aws_iam_group.eks_full_control.arn}
      username: eks-full-control
      groups:
        - eks-full-control-group
EOT
}

# Output the patch content to a file
resource "local_file" "aws_auth_patch" {
  content  = data.template_file.aws_auth_patch.rendered
  filename = "${path.module}/aws-auth-patch.yaml"
}

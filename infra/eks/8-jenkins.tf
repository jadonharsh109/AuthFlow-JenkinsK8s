# Define the Namespace for Jenkins
resource "kubernetes_namespace" "jenkins_ns" {
  metadata {
    name = "jenkins"
  }
  depends_on = [module.eks]
}

# Deploy Jenkins using Helm in the Jenkins Namespace
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins_ns.metadata[0].name

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  set {
    name  = "controller.serviceType"
    value = "LoadBalancer"
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  set {
    name  = "persistence.storageClass"
    value = kubernetes_storage_class.aws_ebs_csi_storage_class.metadata[0].name
  }

  # Enable agents and set dynamic configurations
  set {
    name  = "agent.enabled"
    value = "true"
  }

  set {
    name  = "agent.AlwaysPullImage"
    value = "false"
  }

  set {
    name  = "agent.JNLPLauncher.WorkDir"
    value = "/var/jenkins_home"
  }

  # Enable Jenkins Configuration as Code (JCasC)
  set {
    name  = "controller.JCasC.enabled"
    value = "true"
  }

  set {
    name  = "controller.JCasC.configScripts.my-casc"
    value = <<-EOT
      jenkins:
        agentProtocols:
          - "JNLP4-connect"
    EOT
  }

  depends_on = [
    kubernetes_storage_class.aws_ebs_csi_storage_class,
    kubernetes_namespace.jenkins_ns,
    module.eks
  ]
}

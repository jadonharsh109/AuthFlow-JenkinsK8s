# Define the Namespace for Monitoring
resource "kubernetes_namespace" "monitoring_ns" {
  metadata {
    name = "monitoring"
  }
  depends_on = [module.eks]
}

# Helm release for Prometheus and Grafana
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring_ns.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  # Prometheus settings
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "10d"
  }

  # Prometheus storage configuration
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = kubernetes_storage_class.aws_ebs_csi_storage_class.metadata[0].name
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }

  # Grafana settings
  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = kubernetes_storage_class.aws_ebs_csi_storage_class.metadata[0].name
  }

  set {
    name  = "grafana.persistence.size"
    value = "10Gi"
  }

  # Grafana service type to LoadBalancer
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }

  depends_on = [kubernetes_namespace.monitoring_ns, kubernetes_storage_class.aws_ebs_csi_storage_class]
}

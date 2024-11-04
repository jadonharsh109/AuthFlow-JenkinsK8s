resource "kubernetes_namespace" "monitoring_ns" {
  metadata {
    name = "monitoring"
  }
  depends_on = [module.eks]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring_ns.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "10d"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp2"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "50Gi"
  }

  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = "gp2"
  }

  set {
    name  = "grafana.persistence.size"
    value = "10Gi"
  }

  depends_on = [kubernetes_namespace.monitoring_ns]
}

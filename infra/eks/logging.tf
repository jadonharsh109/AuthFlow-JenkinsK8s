# Define the Namespace for Logging
resource "kubernetes_namespace" "logging_ns" {
  metadata {
    name = "logging"
  }
  depends_on = [module.eks]
}

# Elasticsearch Helm Release
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  namespace  = kubernetes_namespace.logging_ns.metadata[0].name
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "volumeClaimTemplate.storageClassName"
    value = kubernetes_storage_class.aws_ebs_csi_storage_class.metadata[0].name
  }

  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = "10Gi"
  }

  set {
    name  = "persistence.labels.enabled"
    value = "true"
  }

  depends_on = [kubernetes_namespace.logging_ns, kubernetes_storage_class.aws_ebs_csi_storage_class]
}

# Kibana Helm Release
resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = kubernetes_namespace.logging_ns.metadata[0].name
  repository = "https://helm.elastic.co"
  chart      = "kibana"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  depends_on = [kubernetes_namespace.logging_ns]
}

# # Fluentbit Helm Release
# resource "helm_release" "fluentbit" {
#   name       = "fluentbit"
#   namespace  = kubernetes_namespace.logging_ns.metadata[0].name
#   repository = "https://fluent.github.io/helm-charts"
#   chart      = "fluent-bit"

#   values = [
#     yamlencode(yamldecode(file("fluentbit-values.yaml")))
#   ]

#   depends_on = [kubernetes_namespace.logging_ns]
# }

# Define the Namespace for Logging
resource "kubernetes_namespace" "logging_ns" {
  metadata {
    name = "logging"
  }
  depends_on = [module.eks]
}

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

resource "helm_release" "fluentbit" {
  name       = "fluentbit"
  namespace  = kubernetes_namespace.logging_ns.metadata[0].name
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"

  values = [yamlencode(yamldecode(file("fluentbit-values.yaml")))]

  depends_on = [kubernetes_namespace.logging_ns]
}


data "kubernetes_secret" "elasticsearch_credentials" {
  metadata {
    name      = "elasticsearch-master-credentials"
    namespace = kubernetes_namespace.logging_ns.metadata[0].name
  }
}

data "kubernetes_service" "kibana_service" {
  metadata {
    name      = "kibana"                                         # The service name created by the Kibana Helm chart
    namespace = kubernetes_namespace.logging_ns.metadata[0].name # The namespace where Kibana is deployed
  }
}






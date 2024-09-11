resource "kubernetes_cluster_role" "eks_read_only" {
  metadata {
    name = "eks-read-only"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "eks_read_only_binding" {
  metadata {
    name = "eks-read-only-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.eks_read_only.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "eks-read-only-group" # Mapped group from aws-auth
    api_group = "rbac.authorization.k8s.io"
  }
}


resource "kubernetes_cluster_role" "eks_full_control" {
  metadata {
    name = "eks-full-control"
  }

  rule {
    api_groups = [""]
    resources  = ["*"] # All resources
    verbs      = ["*"] # Full control
  }
}

resource "kubernetes_cluster_role_binding" "eks_full_control_binding" {
  metadata {
    name = "eks-full-control-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.eks_full_control.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "eks-full-control-group" # Mapped group from aws-auth
    api_group = "rbac.authorization.k8s.io"
  }
}

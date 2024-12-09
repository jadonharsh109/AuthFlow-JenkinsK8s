# Null resource for executing cleanup commands after namespace deletion
resource "null_resource" "pvc_cleanup" {
  # Trigger this resource only on destroy
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
  }

  # Command to remove finalizers from PVCs, then delete all PVCs in Jenkins and Monitoring namespaces
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "Remove finalizers from all PVCs in the Jenkins namespace"
      for pvc in $(kubectl get pvc -n jenkins -o jsonpath='{.items[*].metadata.name}'); do
        kubectl patch pvc $pvc -n jenkins -p '{"metadata":{"finalizers":null}}' || true
      done
      echo
      echo "Remove finalizers from all PVCs in the Monitoring namespace"
      for pvc in $(kubectl get pvc -n monitoring -o jsonpath='{.items[*].metadata.name}'); do
        kubectl patch pvc $pvc -n monitoring -p '{"metadata":{"finalizers":null}}' || true
      done
      echo
      echo "Delete all PVCs in both namespaces after finalizers are removed"
      kubectl delete pvc --all -n jenkins || true
      kubectl delete pvc --all -n monitoring || true
    EOT
  }

  # Set up dependencies to ensure this runs last
  depends_on = [
    kubernetes_namespace.jenkins_ns,
    kubernetes_namespace.monitoring_ns,
    helm_release.jenkins,
    helm_release.prometheus
  ]
}

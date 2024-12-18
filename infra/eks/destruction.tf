# Null resource for executing cleanup commands after namespace deletion
resource "null_resource" "pvc_cleanup" {
  # Trigger this resource only on destroy
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
  }

  # Command to remove finalizers from PVCs, then delete all PVCs in specified namespaces
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      # Define the namespaces to clean up
      namespaces="jenkins monitoring logging"

      for namespace in $namespaces; do
        echo "Remove finalizers from all PVCs in the $namespace namespace"
        for pvc in $(kubectl get pvc -n $namespace -o jsonpath='{.items[*].metadata.name}'); do
          kubectl patch pvc $pvc -n $namespace -p '{"metadata":{"finalizers":null}}' || true
        done
        echo
      done
    EOT
  }
}

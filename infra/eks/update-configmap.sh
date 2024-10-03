#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
readonly_role="arn:aws:iam::998070853703:role/ReadOnlyAccessRole"
fullaccess_role="arn:aws:iam::998070853703:role/FullAccessRole"

# Helper function for error handling
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Fetch the existing aws-auth ConfigMap
echo "Fetching existing aws-auth ConfigMap..."
kubectl get configmap aws-auth -n kube-system -o yaml > /tmp/aws-auth-configmap.yaml || error_exit "Error: Failed to fetch aws-auth ConfigMap."

# Backup the original ConfigMap
echo "Backing up the original aws-auth ConfigMap..."
cp /tmp/aws-auth-configmap.yaml /tmp/aws-auth-configmap-backup.yaml || error_exit "Error: Failed to backup the original ConfigMap."

# Define the new roles to add as a YAML block
new_roles=$(cat <<EOT
    - rolearn: $readonly_role
      username: readonly
      groups:
        - readonly-group
    - rolearn: $fullaccess_role
      username: fullaccess
      groups:
        - fullaccess-group
EOT
)

# Append the new roles under "mapRoles" in the ConfigMap
echo "Appending new roles to the aws-auth ConfigMap..."
sed -i.bak '/mapRoles:/r /dev/stdin' /tmp/aws-auth-configmap.yaml <<< "$new_roles" || error_exit "Error: Failed to append new roles to the ConfigMap."

# Apply the updated ConfigMap
echo "Applying the updated aws-auth ConfigMap..."
kubectl apply -f /tmp/aws-auth-configmap.yaml || error_exit "Error: Failed to apply the updated aws-auth ConfigMap."

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -f /tmp/aws-auth-configmap.yaml /tmp/aws-auth-configmap-backup.yaml /tmp/aws-auth-configmap.yaml.bak || error_exit "Warning: Failed to clean up temporary files."

# Success message
echo "Updated aws-auth ConfigMap applied successfully!"
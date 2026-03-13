#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

require_cmd az
require_cmd kubectl

print_header "Get AKS credentials"
az aks get-credentials \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --name "$AKS_NAME" \
  --overwrite-existing

if command -v kubelogin >/dev/null 2>&1; then
  kubelogin convert-kubeconfig -l azurecli || true
fi

print_header "Current context"
kubectl config current-context

print_header "Nodes"
kubectl get nodes -o wide

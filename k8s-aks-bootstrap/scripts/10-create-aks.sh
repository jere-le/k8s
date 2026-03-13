#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

require_cmd az

print_header "Azure login and subscription"
az account show >/dev/null 2>&1 || az login

print_header "Create resource group"
az group create \
  --name "$AZ_RESOURCE_GROUP" \
  --location "$AZ_LOCATION" \
  --output table

print_header "Create AKS cluster"
AKS_CREATE_ARGS=(
  --resource-group "$AZ_RESOURCE_GROUP"
  --name "$AKS_NAME"
  --location "$AZ_LOCATION"
  --node-count "$AKS_NODE_COUNT"
  --node-vm-size "$AKS_NODE_VM_SIZE"
  --node-osdisk-size "$AKS_NODE_OSDISK_SIZE"
  --network-plugin "$AKS_NETWORK_PLUGIN"
  --load-balancer-sku "$AKS_LOAD_BALANCER_SKU"
  --generate-ssh-keys
  --enable-managed-identity
  --enable-oidc-issuer
  --enable-workload-identity
  --enable-cluster-autoscaler
  --min-count 1
  --max-count 3
  --tier standard
  --output table
)

if [[ -n "${AKS_K8S_VERSION:-}" ]]; then
  AKS_CREATE_ARGS+=(--kubernetes-version "$AKS_K8S_VERSION")
fi

az aks create "${AKS_CREATE_ARGS[@]}"

print_header "Enable AKS application routing add-on"
az aks approuting enable \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --name "$AKS_NAME" \
  --nginx Internal=None Default=external \
  --output table || \
az aks approuting enable \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --name "$AKS_NAME" \
  --output table

print_header "Cluster created"
az aks show \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --name "$AKS_NAME" \
  --query '{name:name,location:location,kubernetesVersion:kubernetesVersion,provisioningState:provisioningState}' \
  --output table

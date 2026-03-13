#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

require_cmd helm
require_cmd kubectl
require_cmd envsubst

print_header "Create namespace"
kubectl create namespace "$MONITORING_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

print_header "Add Helm repo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

print_header "Render values"
envsubst < "${ROOT_DIR}/monitoring/values.yaml.tmpl" > "${ROOT_DIR}/monitoring/values.generated.yaml"

print_header "Install kube-prometheus-stack"
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace "$MONITORING_NAMESPACE" \
  --values "${ROOT_DIR}/monitoring/values.generated.yaml" \
  --wait \
  --timeout 20m

print_header "Apply ingress manifests"
envsubst < "${ROOT_DIR}/monitoring/grafana-ingress.yaml.tmpl" | kubectl apply -f -
envsubst < "${ROOT_DIR}/monitoring/prometheus-ingress.yaml.tmpl" | kubectl apply -f -

print_header "Monitoring resources"
kubectl get pods -n "$MONITORING_NAMESPACE"
kubectl get ingress -n "$MONITORING_NAMESPACE"

#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

require_cmd kubectl

print_header "Ingress"
kubectl get ingress -A

print_header "Services"
kubectl get svc -A

print_header "Pods"
kubectl get pods -n "$MONITORING_NAMESPACE"

print_header "Grafana admin secret (fallback)"
kubectl get secret -n "$MONITORING_NAMESPACE" kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' 2>/dev/null | base64 -d || true
echo

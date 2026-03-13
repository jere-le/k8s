#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: ${ENV_FILE} missing. Copy .env.example to .env first."
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: required command '$cmd' not found"
    exit 1
  }
}

print_header() {
  echo
  echo "============================================================"
  echo "$1"
  echo "============================================================"
}

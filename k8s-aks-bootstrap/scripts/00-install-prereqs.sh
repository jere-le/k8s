#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"

install_helm() {
  if command -v helm >/dev/null 2>&1; then
    echo "helm already installed"
    return
  fi
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  rm -f get_helm.sh
}

case "$OS" in
  Darwin)
    if command -v brew >/dev/null 2>&1; then
      brew install azure-cli kubectl kubelogin helm
    else
      echo "Homebrew missing. Install it first: https://brew.sh"
      exit 1
    fi
    ;;
  Linux)
    if command -v az >/dev/null 2>&1; then
      echo "azure cli already installed"
    else
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    fi

    if ! command -v unzip >/dev/null 2>&1 || ! command -v envsubst >/dev/null 2>&1; then
      sudo apt-get update
      sudo apt-get install -y unzip gettext-base
    fi

    if ! command -v kubectl >/dev/null 2>&1; then
      sudo az aks install-cli
    fi

    if ! command -v kubelogin >/dev/null 2>&1; then
      curl -LO https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip
      unzip kubelogin-linux-amd64.zip -d kubelogin-tmp
      sudo mv kubelogin-tmp/bin/linux_amd64/kubelogin /usr/local/bin/kubelogin
      rm -rf kubelogin-linux-amd64.zip kubelogin-tmp
    fi

    install_helm
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "Done. Versions:"
az version | head -n 20 || true
kubectl version --client=true || true
kubelogin --version || true
helm version || true

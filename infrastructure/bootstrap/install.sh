#!/bin/bash
set -euo pipefail

# Description: This bash script install K3s, Cert Manager and Rancher. It's supposed to
#              be executed in the node of the management cluster.

# Arguments: This bash script expects the follow arguments in order:
# 1) K3S_VERSION: Version of K3S
# 2) CERT_MANAGER_VERSION: Version of K3S
if [ "$#" -ne 2 ]; then
  echo "Error: Exactly two arguments are required."
  echo "Usage: $0 <K3S_VERSION> <CERT_MANAGER_VERSION>"
  exit 1
fi

K3S_VERSION=$1
CERT_MANAGER_VERSION=$2

# K3s Installation
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION sh -s - server --cluster-init
# --write-kubeconfig-mode 640

export KUBECONFIG="$HOME/.kube/config"
echo "export KUBECONFIG=$KUBECONFIG" >> ~/.bashrc
mkdir -p ~/.kube
sudo k3s kubectl config view --raw > ~/.kube/config
sudo chown -R $USER ~/.kube
# Kubernetes
## Helm
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x /tmp/get_helm.sh
/tmp/get_helm.sh
# Cert Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace
# Rancher
kubectl create namespace cattle-system
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm install rancher rancher-latest/rancher --namespace cattle-system -f values.yaml --namespace cattle-system --create-namespace
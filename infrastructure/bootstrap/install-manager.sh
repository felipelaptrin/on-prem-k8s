#!/bin/bash
set -euo pipefail

# Description: This bash script install K3s, Cert Manager and Rancher. It's supposed to
#              be executed in the node of the management cluster.

# Arguments: This bash script expects the follow arguments in order:
# 1) K3S_VERSION: Version of K3S
# 2) CERT_MANAGER_VERSION: Version of K3S
# 3) RANCHER_VERSION: Version of K3S
# 4) HELM_VALUES_RANCHER_FOLDER_PATH: Path of the folder that contains the custom "values.yaml" file for the Rancher Helm installation

if [ "$#" -ne 4 ]; then
  echo "Error: Exactly 4 arguments are required."
  echo "Usage: $0 <K3S_VERSION> <CERT_MANAGER_VERSION> <RANCHER_VERSION> <HELM_VALUES_RANCHER_FOLDER_PATH>"
  exit 1
fi

K3S_VERSION=$1
CERT_MANAGER_VERSION=$2
RANCHER_VERSION=$3
HELM_VALUES_RANCHER_FOLDER_PATH=$4

# Basic tools
sudo apt-get update
sudo apt install curl jq -y

# K3s Installation
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION sh -s - server --cluster-init
export KUBECONFIG="$HOME/.kube/config"
echo "export KUBECONFIG=$KUBECONFIG" >> $HOME/.bashrc
mkdir -p $HOME/.kube
sudo k3s kubectl config view --raw > $HOME/.kube/config
sudo chmod 600 $HOME/.kube/config

# Kubernetes
## Helm
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x /tmp/get_helm.sh
/tmp/get_helm.sh

## Cert Manager
CERT_MANAGER_NAMESPACE=cert-manager
CERT_MANAGER_HELM_RELEASE=cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
if helm status -n $CERT_MANAGER_NAMESPACE $CERT_MANAGER_HELM_RELEASE > /dev/null 2>&1; then
  echo "Release '$CERT_MANAGER_HELM_RELEASE' exists."
  version=$(helm list -n $CERT_MANAGER_NAMESPACE -o json -a | jq -r .[].app_version)
  if [[ $version != $CERT_MANAGER_VERSION ]]; then
    echo "Upgrading release '$CERT_MANAGER_HELM_RELEASE' to version '$CERT_MANAGER_VERSION'..."
    helm upgrade $CERT_MANAGER_HELM_RELEASE jetstack/cert-manager \
      --namespace $CERT_MANAGER_NAMESPACE --version $CERT_MANAGER_VERSION
  fi
else
  echo "Release '$CERT_MANAGER_HELM_RELEASE' does not exist. Installing version '$CERT_MANAGER_VERSION'..."
  helm install $CERT_MANAGER_HELM_RELEASE jetstack/cert-manager \
    --namespace $CERT_MANAGER_NAMESPACE --version $CERT_MANAGER_VERSION --create-namespace
fi
kubectl -n $CERT_MANAGER_NAMESPACE rollout status deploy/cert-manager

## Rancher
RANCHER_NAMESPACE=cattle-system
RANCHER_HELM_RELEASE=rancher
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
if helm status -n $RANCHER_NAMESPACE $RANCHER_HELM_RELEASE > /dev/null 2>&1; then
  echo "Release '$RANCHER_HELM_RELEASE' exists."
  version=$(helm list -n $RANCHER_NAMESPACE -o json -a | jq -r .[0].app_version)
  if [[ $version != $RANCHER_VERSION ]]; then
    echo "Upgrading release '$RANCHER_HELM_RELEASE' to version '$RANCHER_VERSION'..."
    helm upgrade $RANCHER_HELM_RELEASE rancher-latest/rancher \
      --namespace $RANCHER_NAMESPACE --version $RANCHER_VERSION \
      -f $HELM_VALUES_RANCHER_FOLDER_PATH/values.yaml
  fi
else
  echo "Release '$RANCHER_HELM_RELEASE' does not exist. Installing version '$RANCHER_VERSION'..."
  helm install $RANCHER_HELM_RELEASE rancher-latest/rancher \
    --namespace $RANCHER_NAMESPACE --version $RANCHER_VERSION \
    -f $HELM_VALUES_RANCHER_FOLDER_PATH/values.yaml --create-namespace
  kubectl -n $RANCHER_NAMESPACE rollout status deploy/rancher
  sleep 30
fi
kubectl -n $RANCHER_NAMESPACE rollout status deploy/rancher

# Clean up
rm -rf HELM_VALUES_RANCHER_FOLDER_PATH

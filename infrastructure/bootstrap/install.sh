#!/bin/bash
set -euo pipefail

# Description: This bash script install K3s, Cert Manager and Rancher. It's supposed to
#              be executed in the node of the management cluster.

# Arguments: This bash script expects the follow arguments in order:
# 1) K3S_VERSION: Version of K3S
# 2) CERT_MANAGER_VERSION: Version of K3S
# 3) RANCHER_VERSION: Version of K3S
# 4) HELM_VALUES_RANCHER_FOLDER_PATH: Path of the folder that contains the custom "values.yaml" file for the Rancher Helm installation

echo "Script arguments: $@"

if [ "$#" -ne 4 ]; then
  echo "Error: Exactly 4 arguments are required."
  echo "Usage: $0 <K3S_VERSION> <CERT_MANAGER_VERSION> <RANCHER_VERSION> <HELM_VALUES_RANCHER_FOLDER_PATH>"
  exit 1
fi

K3S_VERSION=$1
CERT_MANAGER_VERSION=$2
RANCHER_VERSION=$3
HELM_VALUES_RANCHER_FOLDER_PATH=$4

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
CERT_MANEGER_HELM_RELEASE=cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
if helm status -n $CERT_MANAGER_NAMESPACE $CERT_MANEGER_HELM_RELEASE > /dev/null 2>&1; then
  echo "Release '$CERT_MANEGER_HELM_RELEASE' exists. Upgrading to version '$CERT_MANAGER_VERSION'..."
  helm upgrade $CERT_MANEGER_HELM_RELEASE jetstack/cert-manager \
    --namespace $CERT_MANAGER_NAMESPACE --version $CERT_MANAGER_VERSION
else
  echo "Release '$CERT_MANEGER_HELM_RELEASE' does not exist. Installing version '$VERSION'..."
  helm install $CERT_MANEGER_HELM_RELEASE jetstack/cert-manager \
    --namespace $CERT_MANAGER_NAMESPACE --version $CERT_MANAGER_VERSION --create-namespace
fi

## Rancher
RANCHER_NAMESPACE=cattle-system
RANCHER_HELM_RELEASE=rancher
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
if helm status -n $RANCHER_NAMESPACE $RANCHER_HELM_RELEASE > /dev/null 2>&1; then
  echo "Release '$RANCHER_HELM_RELEASE' exists. Upgrading to version '$RANCHER_HELM_RELEASE'..."
  helm upgrade $RANCHER_HELM_RELEASE rancher-latest/rancher \
    --namespace $RANCHER_NAMESPACE --version $RANCHER_VERSION \
    -f $HELM_VALUES_RANCHER_FOLDER_PATH/values.yaml
else
  echo "Release '$RANCHER_HELM_RELEASE' does not exist. Installing version '$VERSION'..."
  helm install $RANCHER_HELM_RELEASE rancher-latest/rancher \
    --namespace $RANCHER_NAMESPACE --version $RANCHER_VERSION \
    -f $HELM_VALUES_RANCHER_FOLDER_PATH/values.yaml --create-namespace
fi

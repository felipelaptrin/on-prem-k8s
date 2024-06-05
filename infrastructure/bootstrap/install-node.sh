#!/bin/bash
set -euo pipefail

# Description: This bash script install K3s, Cert Manager and Rancher. It's supposed to
#              be executed in the node of the management cluster.

# Arguments: This bash script expects the follow arguments in order:
# 1) RANCHER_ENDPOINT: Version of K3S
# 2) AUTH_TOKEN: Version of K3S
# 3) CA_CERT: Version of K3S

# # Add Rancher endpoint to /etc/hosts
# sudo echo "rancher $RANCHER_ENDPOINT rancher" >> /etc/hosts

# Disable Swap (Kubernetes requirements)
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# Install recommended packages
sudo apt-get update
sudo apt-get install -y curl tar

# # Register node
# curl -fL https://$RANCHER_ENDPOINT/system-agent-install.sh | sudo  sh -s - --server https://$RANCHER_ENDPOINT \
#   --token $AUTH_TOKEN \
#   --etcd --controlplane --worker
#   # --ca-checksum $CA_CERT \
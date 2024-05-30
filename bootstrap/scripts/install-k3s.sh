#!/bin/bash
set -o pipefail

# Expects the follow arguments in order:
# 1) K3S_VERSION: Version of K3S

if [ -z "$1" ]; then
  echo "Error: K3S_VERSION argument is required."
  echo "Usage: $0 <K3S_VERSION>"
  exit 1
fi

K3S_VERSION=$1

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION sh -s - server --cluster-init

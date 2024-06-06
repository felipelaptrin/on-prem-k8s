#!/bin/bash
set -euo pipefail

# Description: This bash script applies best practices for Kubernetes nodes.

# Disable Swap (Kubernetes requirements)
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# Install recommended packages
sudo apt-get update
sudo apt-get install -y curl tar

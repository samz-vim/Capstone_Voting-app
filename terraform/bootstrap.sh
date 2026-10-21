#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/nationalvote-bootstrap.log) 2>&1
trap 'rc=$?; echo "ERROR at line ${LINENO}, exit code ${rc}"; exit "$rc"' ERR

export DEBIAN_FRONTEND=noninteractive

echo "===== NationalVote Kubernetes setup started ====="
date

# Install prerequisites
apt-get update
apt-get install -y curl ca-certificates

# Install lightweight Kubernetes (K3s)
curl -fsSL https://get.k3s.io -o /tmp/install-k3s.sh
INSTALL_K3S_CHANNEL=stable sh /tmp/install-k3s.sh

# Verify K3s is running
systemctl enable --now k3s
systemctl is-active --quiet k3s

# Wait for the Kubernetes node to become Ready
/usr/local/bin/k3s kubectl wait \
  --for=condition=Ready \
  nodes --all \
  --timeout=300s

# Configure kubectl for Ubuntu
if [ ! -e /usr/local/bin/kubectl ]; then
  ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
fi

install -d -o ubuntu -g ubuntu -m 700 /home/ubuntu/.kube
install -o ubuntu -g ubuntu -m 600 \
  /etc/rancher/k3s/k3s.yaml \
  /home/ubuntu/.kube/config

# Install Helm
curl -fsSL \
  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  -o /tmp/get_helm.sh

chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh

# Verify both tools
/usr/local/bin/k3s kubectl get nodes
/usr/local/bin/helm version

# Mark setup complete only after successful verification
touch /var/lib/nationalvote-bootstrap-complete

echo "===== NationalVote Kubernetes setup completed ====="
date

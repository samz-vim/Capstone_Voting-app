#!/bin/bash
set -Eeuo pipefail

# Log all output for troubleshooting
exec > >(tee -a /var/log/nationalvote-bootstrap.log) 2>&1

trap 'rc=$?; echo "ERROR: Bootstrap failed at line ${LINENO}, exit code ${rc}"; exit "$rc"' ERR

export DEBIAN_FRONTEND=noninteractive

echo "=========================================="
echo " NationalVote Kubernetes Bootstrap"
echo "=========================================="
date

# --------------------------------------------------
# 1. Wait for cloud-init to finish its own work
# --------------------------------------------------
echo "Checking cloud-init status..."

if command -v cloud-init >/dev/null 2>&1; then
    cloud-init status --wait || true
fi

# --------------------------------------------------
# 2. Wait for apt/dpkg locks without deleting them
# --------------------------------------------------
echo "Waiting for package manager locks..."

for attempt in $(seq 1 60); do
    if ! fuser \
        /var/lib/dpkg/lock-frontend \
        /var/lib/dpkg/lock \
        /var/cache/apt/archives/lock \
        >/dev/null 2>&1; then
        break
    fi

    if [ "$attempt" -eq 60 ]; then
        echo "ERROR: Package manager is still busy after 10 minutes."
        echo "Inspect running apt/dpkg processes before retrying."
        ps aux | grep -E '[a]pt-get|[a]pt |[d]pkg'
        exit 1
    fi

    echo "Package manager is busy; waiting ($attempt/60)..."
    sleep 10
done

# --------------------------------------------------
# 3. Install prerequisites
# --------------------------------------------------
echo "Updating package lists..."
apt-get update

echo "Installing prerequisites..."
apt-get install -y curl ca-certificates

# --------------------------------------------------
# 4. Install lightweight Kubernetes: K3s
# --------------------------------------------------
echo "Installing K3s..."

curl -fsSL https://get.k3s.io -o /tmp/install-k3s.sh
INSTALL_K3S_CHANNEL=stable sh /tmp/install-k3s.sh

# --------------------------------------------------
# 5. Start and verify K3s
# --------------------------------------------------
echo "Starting Kubernetes..."

systemctl enable --now k3s
systemctl is-active --quiet k3s

echo "Waiting for Kubernetes node to become Ready..."

/usr/local/bin/k3s kubectl wait \
    --for=condition=Ready \
    nodes --all \
    --timeout=300s

# --------------------------------------------------
# 6. Configure kubectl for the Ubuntu user
# --------------------------------------------------
echo "Configuring kubectl..."

if [ ! -e /usr/local/bin/kubectl ]; then
    ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
fi

install -d -o ubuntu -g ubuntu -m 700 /home/ubuntu/.kube

install -o ubuntu -g ubuntu -m 600 \
    /etc/rancher/k3s/k3s.yaml \
    /home/ubuntu/.kube/config

# --------------------------------------------------
# 7. Install Helm
# --------------------------------------------------
echo "Installing Helm..."

curl -fsSL \
    https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    -o /tmp/get_helm.sh

chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh

# --------------------------------------------------
# 8. Verify the installation
# --------------------------------------------------
echo "Verifying Kubernetes..."

/usr/local/bin/k3s kubectl get nodes
/usr/local/bin/k3s kubectl get pods -A
/usr/local/bin/helm version

# --------------------------------------------------
# 9. Mark bootstrap complete
# --------------------------------------------------
touch /var/lib/nationalvote-bootstrap-complete

echo "=========================================="
echo " K3s and Helm installed successfully"
echo " Application deployment comes next"
echo "=========================================="
date

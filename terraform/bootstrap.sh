#!/bin/bash
set -Eeuo pipefail
set -x

# Log all output for troubleshooting.
exec > >(tee -a /var/log/nationalvote-bootstrap.log) 2>&1

trap 'rc=$?; echo "ERROR: Bootstrap failed at line ${LINENO} with exit code ${rc}"; exit "$rc"' ERR

export DEBIAN_FRONTEND=noninteractive

echo "===== Starting NationalVote EC2 bootstrap ====="
date

# 1. Prepare Ubuntu and install containerd.
apt-get update
apt-get install -y 
  ca-certificates 
  curl 
  gpg 
  apt-transport-https 
  containerd

swapoff -a
sed -i '/[[:space:]]swap[[:space:]]/s/^[^#]/#&/' /etc/fstab

# 2. Configure containerd to use systemd cgroups.
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' 
  /etc/containerd/config.toml

systemctl enable containerd
systemctl restart containerd
systemctl is-active --quiet containerd

# 3. Install Kubernetes packages.
mkdir -p /etc/apt/keyrings

curl -fsSL 
  https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key 
  | gpg --dearmor --yes 
      -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 
  "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# 4. Enable IPv4 forwarding.
cat > /etc/sysctl.d/99-kubernetes.conf <<'SYSCTL_EOF'
net.ipv4.ip_forward = 1
SYSCTL_EOF

sysctl --system
test "$(sysctl -n net.ipv4.ip_forward)" = "1"

# 5. Initialize the single-node Kubernetes cluster.
kubeadm init 
  --pod-network-cidr=10.244.0.0/16 
  --cri-socket=unix:///run/containerd/containerd.sock

# Configure kubectl for the ubuntu user.
install -d -o ubuntu -g ubuntu /home/ubuntu/.kube
install -o ubuntu -g ubuntu -m 600 
  /etc/kubernetes/admin.conf /home/ubuntu/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

# 6. Install Flannel networking.
kubectl apply -f 
  https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Allow application and monitoring workloads on this single node.
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

# Wait for Kubernetes and its networking to become ready.
kubectl wait --for=condition=Ready nodes --all --timeout=10m

# 7. Install Helm.
curl -fsSL 
  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 
  -o /tmp/get_helm.sh

chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh
helm version

# 8. Install Prometheus and Grafana.
helm repo add prometheus-community 
  https://prometheus-community.github.io/helm-charts

helm repo update

kubectl create namespace monitoring 
  --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install monitoring 
  prometheus-community/kube-prometheus-stack 
  --namespace monitoring 
  --wait 
  --timeout 20m

# 9. Verify key components before declaring success.
kubectl get nodes
kubectl get pods -A

# Create the completion marker only after every step succeeds.
touch /var/lib/nationalvote-bootstrap-complete

echo "===== NationalVote bootstrap completed successfully ====="
date

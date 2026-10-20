
#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/nationalvote-bootstrap.log) 2>&1

export DEBIAN_FRONTEND=noninteractive

# 1. Prepare Ubuntu
apt-get update
apt-get install -y \
  ca-certificates curl gpg apt-transport-https \
  containerd

swapoff -a
sed -i '/\sswap\s/s/^/#/' /etc/fstab

# 2. Configure containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

sed -i \
  's/SystemdCgroup = false/SystemdCgroup = true/' \
  /etc/containerd/config.toml

systemctl enable --now containerd
systemctl restart containerd

# 3. Install Kubernetes packages
mkdir -p /etc/apt/keyrings

curl -fsSL \
  https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key \
  | gpg --dearmor --yes \
      -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo \
  "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Enable packet forwarding
cat > /etc/sysctl.d/99-kubernetes.conf <<'EOF'
net.ipv4.ip_forward = 1
EOF

sysctl --system

# 4. Initialize a single-node Kubernetes cluster
kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock

# Configure kubectl for the Ubuntu user
install -d -o ubuntu -g ubuntu /home/ubuntu/.kube
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

# 5. Install Flannel pod networking
kubectl apply -f \
  https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Permit application and monitoring pods to run on this
# single control-plane node.
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

# Wait for cluster networking to become ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# 6. Install Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  -o /tmp/get_helm.sh

chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh

# 7. Install Prometheus and Grafana using Helm
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

helm repo update

kubectl create namespace monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install monitoring \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --wait \
  --timeout 15m

# 8. Record bootstrap completion
touch /var/lib/nationalvote-bootstrap-complete
echo "Kubernetes, Helm and monitoring installation completed."

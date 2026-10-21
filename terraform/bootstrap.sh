#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/nationalvote-bootstrap.log) 2>&1

echo "===== NationalVote bootstrap started ====="

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl

# Install Docker
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh

# Start Docker automatically
systemctl enable --now docker

# Confirm Docker works
docker --version
docker info

# Allow the Ubuntu user to use Docker
usermod -aG docker ubuntu

# Mark bootstrap as complete
touch /var/lib/nationalvote-bootstrap-complete

echo "===== NationalVote bootstrap completed successfully ====="

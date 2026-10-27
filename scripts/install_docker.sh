#!/usr/bin/env bash
set -Eeuo pipefail

# https://docs.docker.com/engine/install/ubuntu/

remove_old_docker_packages() {
  set +e
  sudo apt-get remove -y \
  docker \
  docker-engine \
  docker.io \
  containerd \
  runc > /dev/null
  set -e
}

remove_old_docker_packages

# create the docker repo signature key if necessary
if [ ! -f /etc/apt/keyrings/docker.gpg ]
then
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL \
  https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

# always rewrite so the codename tracks the running release; a list file left
# over from an earlier Ubuntu (e.g. noble after an upgrade) would go stale
echo \
"deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-compose-plugin

# 'install' is a no-op when docker is already present; force the upgrade to latest
sudo apt-get install -y --only-upgrade \
docker-ce \
docker-ce-cli \
containerd.io \
docker-compose-plugin

sudo usermod -aG docker "${USER}"

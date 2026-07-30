#!/usr/bin/env bash
set -Eeuo pipefail
if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /tmp/hashicorp-archive-keyring.gpg
  sudo mv /tmp/hashicorp-archive-keyring.gpg /usr/share/keyrings/hashicorp-archive-keyring.gpg
else
  echo "file already exists: /usr/share/keyrings/hashicorp-archive-keyring.gpg"
fi

if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
else
  echo "file already exists: /etc/apt/sources.list.d/hashicorp.list"
fi
sudo apt update && sudo apt install packer
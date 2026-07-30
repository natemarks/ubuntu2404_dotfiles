#!/usr/bin/env bash
set -Eeuo pipefail

# https://tailscale.com/kb/1031/install-linux

if [ ! -f /etc/apt/keyrings/tailscale-archive-keyring.gpg ]
then
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL \
  https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | \
  sudo tee /etc/apt/keyrings/tailscale-archive-keyring.gpg > /dev/null
fi

if [ ! -f /etc/apt/sources.list.d/tailscale.list ]
then
  echo \
  "deb [signed-by=/etc/apt/keyrings/tailscale-archive-keyring.gpg] \
  https://pkgs.tailscale.com/stable/ubuntu focal main" | \
  sudo tee /etc/apt/sources.list.d/tailscale.list > /dev/null
fi

sudo apt-get update
sudo apt-get install -y tailscale


# Start Tailscale with posture checking and route acceptance enabled
sudo tailscale up --accept-routes=true --report-posture=true -operator=nmarks

#!/usr/bin/env bash
set -euo pipefail

# Install Claude Desktop and configure /dev/kvm access for Cowork.
# Cowork also needs /dev/vhost-vsock, which requires the kvm group even if
# /dev/kvm is already accessible without it.

KEYRING=/usr/share/keyrings/claude-desktop-archive-keyring.asc
SOURCES=/etc/apt/sources.list.d/claude-desktop.list

# Add current user to kvm group if not already a member
if ! groups "$USER" | grep -qw kvm; then
    echo "Adding $USER to kvm group..."
    sudo usermod -aG kvm "$USER"
    echo "Added. Log out and back in for the group change to take effect."
else
    echo "$USER is already in the kvm group."
fi

# Add apt repo keyring
if [[ ! -f "$KEYRING" ]]; then
    echo "Installing Claude Desktop apt keyring..."
    sudo curl -fsSLo "$KEYRING" https://downloads.claude.ai/claude-desktop/key.asc
fi

gpg --show-keys "$KEYRING"

# Add apt sources entry
if [[ ! -f "$SOURCES" ]]; then
    echo "Adding Claude Desktop apt repository..."
    echo "deb [arch=amd64,arm64 signed-by=${KEYRING}] https://downloads.claude.ai/claude-desktop/apt/stable stable main" \
        | sudo tee "$SOURCES"
fi

sudo apt update && sudo apt install -y claude-desktop

echo ""
echo "Done. If you were just added to the kvm group, log out and back in before using Cowork."

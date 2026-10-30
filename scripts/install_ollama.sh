#!/usr/bin/env bash
set -Eeuo pipefail

# https://ollama.com/download/linux
# Pinned to a known-good version; bump OLLAMA_VERSION deliberately to upgrade.
# Ollama runs as a user service with OLLAMA_MODELS in a directory we own, not
# as the stock `ollama` system user (see ollama/ollama.service).

OLLAMA_VERSION=0.23.3
PRJ=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
UNIT_DIR="$HOME/.config/systemd/user"

if ! command -v ollama >/dev/null 2>&1 || ! ollama --version 2>&1 | grep -qF "$OLLAMA_VERSION"; then
    curl -fsSL https://ollama.com/install.sh | OLLAMA_VERSION="$OLLAMA_VERSION" sh
fi

# The installer enables the system service, which holds port 11434.
if systemctl cat ollama.service >/dev/null 2>&1; then
    sudo systemctl disable --now ollama
fi

mkdir -p "$HOME/ollama-models" "$UNIT_DIR"
ln -sfn "$PRJ/ollama/ollama.service" "$UNIT_DIR/ollama.service"

systemctl --user daemon-reload
systemctl --user enable --now ollama
# Keep the user service running without an active login.
loginctl enable-linger "$USER"

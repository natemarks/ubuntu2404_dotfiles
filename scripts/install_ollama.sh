#!/usr/bin/env bash
set -Eeuo pipefail

# https://ollama.com/download/linux
# Pinned to a known-good version; bump OLLAMA_VERSION deliberately to upgrade.

curl -fsSL https://ollama.com/install.sh | OLLAMA_VERSION=0.23.3 sh

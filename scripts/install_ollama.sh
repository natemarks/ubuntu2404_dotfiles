#!/usr/bin/env bash
set -Eeuo pipefail

# https://ollama.com/download/linux
# Always re-runs the upstream installer so ollama is updated/overwritten to latest.

curl -fsSL https://ollama.com/install.sh | sh

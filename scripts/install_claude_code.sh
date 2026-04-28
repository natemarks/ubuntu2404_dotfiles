#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v npm >/dev/null 2>&1; then
    echo "ERROR: npm is required to install Claude Code." >&2
    exit 1
fi

npm install @anthropic-ai/claude-code

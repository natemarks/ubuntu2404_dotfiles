#!/usr/bin/env bash
set -Eeuo pipefail

# Installs or upgrades cfn-lint to the latest PyPI release as an isolated uv tool,
# with its executable placed in ~/bin. Requires uv (make uv).
# Set VERSION=x.y.z to install a specific release instead.
BIN_DIR="${HOME}/bin"

if ! command -v uv >/dev/null 2>&1; then
  echo "ERROR: uv is not installed; run 'make uv' first" >&2
  exit 1
fi

mkdir -p "${BIN_DIR}"
export UV_TOOL_BIN_DIR="${BIN_DIR}"

if [[ -n "${VERSION:-}" ]]; then
  uv tool install --force "cfn-lint==${VERSION}"
else
  uv tool install --force --upgrade cfn-lint
fi

echo "Installed $("${BIN_DIR}/cfn-lint" --version) to ${BIN_DIR}/cfn-lint"

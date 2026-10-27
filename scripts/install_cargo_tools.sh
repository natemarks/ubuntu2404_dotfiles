#!/usr/bin/env bash
set -Eeuo pipefail

# Installs the standard cargo-based tools. Re-running upgrades them to the latest release.
# Requires rustup (make rustup); build-essential and libssl-dev come from make packages.
# Add a tool by appending its crate name to CARGO_TOOLS.
CARGO_TOOLS=(
  cargo-audit
  cargo-deny
)

export PATH="${HOME}/.cargo/bin:${PATH}"

if ! command -v cargo >/dev/null; then
  echo "ERROR: cargo not found; run 'make rustup' first" >&2
  exit 1
fi

for tool in "${CARGO_TOOLS[@]}"; do
  echo "Installing ${tool}"
  # --locked builds against the crate's tested Cargo.lock
  cargo install --locked "${tool}"
done

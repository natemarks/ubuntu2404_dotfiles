#!/usr/bin/env bash
set -Eeuo pipefail

# Install Rust toolchain (rustc, cargo, rustup) for Ubuntu 24.04
# https://www.rust-lang.org/tools/install

echo "Installing Rust toolchain on Ubuntu 24.04..."

# Install build dependencies required for Rust
echo "Installing system dependencies..."
if ! dpkg -l | grep -q build-essential; then
  sudo apt-get update
  sudo apt-get install -y build-essential curl
fi

# Check if rustup is already installed
if command -v rustup &> /dev/null; then
  echo "rustup already installed, updating..."
  rustup update
else
  echo "Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

  # Source cargo env for current session
  # shellcheck source=/dev/null
  source "${HOME}/.cargo/env"
fi

# Ensure we have the stable toolchain
rustup toolchain install stable
rustup default stable

# Install additional components
echo "Installing Rust components..."
rustup component add rust-analyzer
rustup component add clippy
rustup component add rustfmt

echo "Rust toolchain installation complete!"
echo ""

# Verify installation
echo "Verifying installation..."
VERIFICATION_FAILED=0

if ! command -v rustc &> /dev/null; then
  echo "❌ ERROR: rustc not found in PATH"
  VERIFICATION_FAILED=1
else
  echo "✓ rustc: $(rustc --version)"
fi

if ! command -v cargo &> /dev/null; then
  echo "❌ ERROR: cargo not found in PATH"
  VERIFICATION_FAILED=1
else
  echo "✓ cargo: $(cargo --version)"
fi

if ! command -v rustup &> /dev/null; then
  echo "❌ ERROR: rustup not found in PATH"
  VERIFICATION_FAILED=1
else
  echo "✓ rustup: $(rustup --version)"
fi

# Check components
COMPONENTS=$(rustup component list --installed)
for component in rust-analyzer clippy rustfmt; do
  if echo "${COMPONENTS}" | grep -q "${component}"; then
    echo "✓ ${component} installed"
  else
    echo "❌ WARNING: ${component} not installed"
    VERIFICATION_FAILED=1
  fi
done

echo ""
if [ ${VERIFICATION_FAILED} -eq 0 ]; then
  echo "✓ All components verified successfully!"
  echo ""
  echo "Note: If this is your first install, you may need to:"
  echo "  1. Add cargo to your PATH by running: source \$HOME/.cargo/env"
  echo "  2. Or start a new shell session: exec bash"
else
  echo "⚠ Verification failed. Please try the following:"
  echo ""
  echo "1. Source the cargo environment:"
  echo "   source \$HOME/.cargo/env"
  echo ""
  echo "2. Or start a new shell session:"
  echo "   exec bash"
  echo ""
  echo "3. Then verify manually:"
  echo "   rustc --version"
  echo "   cargo --version"
  echo "   rustup component list --installed"
  exit 1
fi

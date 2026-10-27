#!/usr/bin/env bash
set -Eeuo pipefail

# Installs rustup (creates ~/.cargo and ~/.rustup), always using the latest rustup-init.
# Re-running upgrades rustup in place and updates the default toolchain.
# PATH is handled by bashrc.d/rustup_path.sh, so shell profiles are left alone.
case "$(uname -m)" in
  x86_64) TRIPLE="x86_64-unknown-linux-gnu" ;;
  aarch64) TRIPLE="aarch64-unknown-linux-gnu" ;;
  *)
    echo "ERROR: unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

BASE_URL="https://static.rust-lang.org/rustup/dist/${TRIPLE}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Downloading ${BASE_URL}/rustup-init"
curl --proto '=https' --tlsv1.2 -fsSL "${BASE_URL}/rustup-init" -o "${tmpdir}/rustup-init"
curl --proto '=https' --tlsv1.2 -fsSL "${BASE_URL}/rustup-init.sha256" -o "${tmpdir}/rustup-init.sha256"

expected="$(awk '{print $1}' "${tmpdir}/rustup-init.sha256")"
if ! echo "${expected}  ${tmpdir}/rustup-init" | sha256sum --check --quiet; then
  echo "ERROR: checksum verification failed for rustup-init" >&2
  exit 1
fi

chmod +x "${tmpdir}/rustup-init"
"${tmpdir}/rustup-init" -y --no-modify-path

# neovim's rust-analyzer/clippy settings (see neovim config) expect these components
"${HOME}/.cargo/bin/rustup" component add clippy rustfmt rust-analyzer

echo "Installed $("${HOME}/.cargo/bin/rustup" --version 2>/dev/null)"

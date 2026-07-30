#!/usr/bin/env bash
set -Eeuo pipefail

# install rustup
#  creates ~/.cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

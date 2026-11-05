#!/usr/bin/env bash
# Tailscale aliases for common operations

alias ts='tailscale'
alias tss='tailscale status'
alias tsd='sudo tailscale down'

# Exit node used for full-tunnel mode
TS_EXIT_NODE=100.84.119.96
# `tailscale up` errors if any non-default flag is omitted, so every non-default
# flag must be listed here and passed on each invocation of tsfull/tssplit.
TS_BASE_FLAGS='--accept-routes=true --report-posture=true'

# Full tunnel: connect (if needed) and route all traffic via the exit node,
# keeping the local LAN reachable.
alias tsfull='sudo tailscale up $TS_BASE_FLAGS --exit-node=$TS_EXIT_NODE --exit-node-allow-lan-access=true'
# Split tunnel: connect (if needed) with no exit node (tailnet traffic only).
alias tssplit='sudo tailscale up $TS_BASE_FLAGS --exit-node= --exit-node-allow-lan-access=false'
alias tsip='tailscale ip'
alias tsping='tailscale ping'
alias tsssh='tailscale ssh'

#!/usr/bin/env bash
set -Eeuo pipefail

# Installs/updates uv (which provides uvx) using Astral's installer,
# then optionally installs/updates a persistent MCP agent tool.
#
# Usage:
#   scripts/install_uvx_mcp_agent.sh [mcp-agent-spec]
#
# Examples:
#   scripts/install_uvx_mcp_agent.sh
#   scripts/install_uvx_mcp_agent.sh mcp-agent
#   scripts/install_uvx_mcp_agent.sh "mcp-agent==0.7.1"

UV_INSTALL_URL="https://astral.sh/uv/install.sh"
DEFAULT_MCP_AGENT_SPEC="mcp-agent"
MCP_AGENT_SPEC="${1:-${MCP_AGENT_SPEC:-${DEFAULT_MCP_AGENT_SPEC}}}"

log() {
	printf '[install_uvx_mcp_agent] %s\n' "$*"
}

fail() {
	printf '[install_uvx_mcp_agent] ERROR: %s\n' "$*" >&2
	exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	sed -n '1,16p' "$0"
	exit 0
fi

command -v curl >/dev/null 2>&1 || fail "curl is required"

tmp_install_script="$(mktemp)"
cleanup() {
	rm -f -- "$tmp_install_script"
}
trap cleanup EXIT

log "Downloading uv installer from ${UV_INSTALL_URL}"
curl -LsSf "$UV_INSTALL_URL" -o "$tmp_install_script"

log "Running uv installer (equivalent to: curl -LsSf ${UV_INSTALL_URL} | sh)"
sh "$tmp_install_script"

# Ensure uv/uvx are visible in this shell after install.
if [[ -d "${HOME}/.local/bin" ]]; then
	case ":${PATH}:" in
	*":${HOME}/.local/bin:"*) ;;
	*) export PATH="${HOME}/.local/bin:${PATH}" ;;
	esac
fi

command -v uv >/dev/null 2>&1 || fail "uv not found after install; ensure ~/.local/bin is in PATH"
command -v uvx >/dev/null 2>&1 || fail "uvx not found after install; ensure ~/.local/bin is in PATH"

log "uv version: $(uv --version)"

log "Installing/updating MCP agent tool: ${MCP_AGENT_SPEC}"
uv tool install --upgrade "$MCP_AGENT_SPEC"
log "Installed/updated '${MCP_AGENT_SPEC}'."
log "Run it via: uvx ${MCP_AGENT_SPEC%%=*} --help"

log "Done."

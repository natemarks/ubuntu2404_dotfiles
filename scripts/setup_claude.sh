#!/usr/bin/env bash
set -euo pipefail

# Reconfigure Claude Code MCP servers on a fresh installation.
#
# MCP servers live in ~/.claude.json (user scope) and persist across all
# sessions and settings profiles. Run this once after installing Claude Code.
#
# Usage:
#   bash scripts/setup_claude.sh
#
# Requires BRAVE_API_KEY in the environment. If not set, the script tries to
# read it from an existing ~/.claude.json brave-search entry.

# -- Resolve BRAVE_API_KEY ---------------------------------------------------

if [[ -z "${BRAVE_API_KEY:-}" ]]; then
    BRAVE_API_KEY=$(python3 - <<'EOF'
import json, sys
try:
    with open(__import__('os').path.expanduser('~/.claude.json')) as f:
        d = json.load(f)
    for arg in d.get('mcpServers', {}).get('brave-search', {}).get('args', []):
        if arg.startswith('BRAVE_API_KEY='):
            print(arg.split('=', 1)[1])
            sys.exit(0)
except Exception:
    pass
sys.exit(1)
EOF
) || true
fi

if [[ -z "${BRAVE_API_KEY:-}" ]]; then
    echo "Error: BRAVE_API_KEY not found. Set it in the environment:" >&2
    echo "  BRAVE_API_KEY=<key> bash scripts/setup_claude.sh" >&2
    exit 1
fi

# -- Helper ------------------------------------------------------------------

mcp_add() {
    local name="$1"
    shift
    claude mcp remove "$name" 2>/dev/null || true
    claude mcp add --scope user "$@"
    echo "  configured: $name"
}

# -- MCP servers -------------------------------------------------------------

echo "Configuring Claude Code MCP servers (user scope)..."

mcp_add brave-search \
    -e "BRAVE_API_KEY=${BRAVE_API_KEY}" \
    -- npx -y @modelcontextprotocol/server-brave-search

mcp_add aws-docs \
    -e "FASTMCP_LOG_LEVEL=ERROR" \
    -e "AWS_DOCUMENTATION_PARTITION=aws" \
    -- uvx awslabs.aws-documentation-mcp-server@latest

mcp_add aws-pricing \
    -e "FASTMCP_LOG_LEVEL=ERROR" \
    -e "AWS_PROFILE=claude-code" \
    -e "AWS_REGION=us-east-1" \
    -- uvx awslabs.aws-pricing-mcp-server@latest

mcp_add aws-billing \
    -e "FASTMCP_LOG_LEVEL=ERROR" \
    -e "AWS_PROFILE=claude-code" \
    -e "AWS_REGION=us-east-1" \
    -- uvx awslabs.billing-cost-management-mcp-server@latest

mcp_add aws-iac \
    -e "AWS_PROFILE=claude-code" \
    -e "FASTMCP_LOG_LEVEL=ERROR" \
    -- uvx awslabs.aws-iac-mcp-server@latest

mcp_add runbook-mcp-local \
    --transport sse \
    http://localhost:8000/sse

echo ""
echo "Done. Verify with: claude mcp list"

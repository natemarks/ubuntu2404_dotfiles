#!/usr/bin/env bash
set -euo pipefail

# Install Claude Code plugins on a fresh machine. Idempotent.
#
# - aws-core: Agent Toolkit for AWS. Bundles the managed AWS MCP Server
#   config, AWS skills and hooks.
#   https://docs.aws.amazon.com/agent-toolkit/latest/userguide/quick-start.html
# - mattpocock-skills: engineering/productivity skills from the official
#   Claude plugin marketplace.
#
# - atlassian: Atlassian Rovo MCP server for Jira and Confluence.
#
# The same plugins are declared in claude/settings.json (enabledPlugins), so
# this script only has to fetch them.
#
# Usage:
#   bash scripts/install_claude_plugins.sh

if ! command -v claude >/dev/null 2>&1; then
    echo "Error: claude CLI not found. Run 'make claude' first." >&2
    exit 1
fi

AWS_MARKETPLACE="aws/agent-toolkit-for-aws"

# Marketplace names are stable identifiers from each marketplace.json.
AWS_MARKETPLACE_NAME="agent-toolkit-for-aws"
OFFICIAL_MARKETPLACE_NAME="claude-plugins-official"

installed=$(claude plugin list 2>/dev/null || true)

install_plugin() {
    local plugin="$1"
    if grep -q "$plugin" <<<"$installed"; then
        echo "  already installed: $plugin"
    else
        claude plugin install "$plugin"
        echo "  installed: $plugin"
    fi
}

echo "Configuring Claude Code plugins..."

# claude-plugins-official is built in; only add the AWS marketplace if absent.
if claude plugin marketplace list 2>/dev/null | grep -q "$AWS_MARKETPLACE_NAME"; then
    echo "  marketplace present: $AWS_MARKETPLACE_NAME"
else
    claude plugin marketplace add "$AWS_MARKETPLACE"
fi

install_plugin "aws-core@${AWS_MARKETPLACE_NAME}"
install_plugin "mattpocock-skills@${OFFICIAL_MARKETPLACE_NAME}"
# Atlassian Rovo MCP server (Jira + Confluence). OAuth sign-in is a one-time
# manual step: run /mcp inside Claude Code afterwards.
install_plugin "atlassian@${OFFICIAL_MARKETPLACE_NAME}"

echo ""
echo "Done. Verify with: claude plugin list"

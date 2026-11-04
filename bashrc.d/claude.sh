#!/usr/bin/env bash

# Switch Claude Code between AWS Bedrock (work) and Anthropic API (personal).
#
# Model preferences for the Anthropic API are in ~/.claude/settings.json
# (symlinked from this repo's claude/settings.json). Bedrock model IDs and
# AWS credentials are in ~/.claude/settings.imprivata.json.
#
# Usage:
#   claude_bedrock    - switch current shell to Bedrock
#   claude_anthropic  - switch current shell to Anthropic API (relinks settings,
#                       logs in if signed out)
#   claude_backend    - show active backend

claude_bedrock() {
    export CLAUDE_CODE_USE_BEDROCK=1
    export AWS_PROFILE=claude-code
    export AWS_REGION=us-east-1
    export CLAUDE_CODE_SETTINGS_FILE="${HOME}/.claude/settings.imprivata.json"
    unset ANTHROPIC_API_KEY
}

# Repo root, resolved through the ~/bashrc.d symlink. The Makefile uses $PWD
# for its paths, so make must be run from inside the repo.
CLAUDE_DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

claude_anthropic() {
    unset CLAUDE_CODE_USE_BEDROCK
    unset AWS_PROFILE
    unset AWS_REGION
    unset CLAUDE_CODE_SETTINGS_FILE
    # Clear any Bedrock model vars that may have leaked into the shell
    unset ANTHROPIC_DEFAULT_SONNET_MODEL
    unset ANTHROPIC_DEFAULT_OPUS_MODEL
    unset ANTHROPIC_DEFAULT_HAIKU_MODEL

    # Relink ~/.claude/settings.json to the Anthropic settings; a settings-file
    # env block overrides shell exports, so the link must match the backend.
    if ! (cd "${CLAUDE_DOTFILES_DIR}" && make --no-print-directory claude_anthropic_settings); then
        echo "claude_anthropic: failed to link anthropic settings" >&2
        return 1
    fi

    # Login is interactive (opens a browser); the target skips it when already
    # signed in. The email is not stored in the repo: export
    # CLAUDE_ANTHROPIC_EMAIL from an untracked file such as ~/.bashrc.
    (cd "${CLAUDE_DOTFILES_DIR}" && make --no-print-directory claude_login EMAIL="${CLAUDE_ANTHROPIC_EMAIL:-}")
}

claude_backend() {
    if [[ -n "${CLAUDE_CODE_USE_BEDROCK:-}" ]]; then
        echo "backend : bedrock"
        echo "profile : ${AWS_PROFILE:-unset}"
        echo "settings: ${CLAUDE_CODE_SETTINGS_FILE}"
    else
        echo "backend : anthropic api"
        echo "model   : $(python3 -c "import json; print(json.load(open('${HOME}/.claude/settings.json')).get('model','(default)'))" 2>/dev/null || echo "(unknown)")"
    fi
}

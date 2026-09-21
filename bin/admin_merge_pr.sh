#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <pr-number>" >&2
    exit 1
fi

PR_NUMBER="$1"

if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Error: PR number must be a positive integer, got: $PR_NUMBER" >&2
    exit 1
fi

gh pr merge "$PR_NUMBER" --admin --squash

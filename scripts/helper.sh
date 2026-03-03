#!/usr/bin/env bash
check_sha256() {
    local file="$1"
    local expected="$2"

    if [[ -z "$file" || -z "$expected" ]]; then
        echo "ERROR: usage: check_sha256 <file> <expected_sha256>" >&2
        return 2
    fi

    if [[ ! -f "$file" ]]; then
        echo "ERROR: file not found: $file" >&2
        return 3
    fi

    local actual
    if ! actual="$(sha256sum -- "$file" 2>/dev/null | awk '{print $1}')"; then
        echo "ERROR: failed to compute sha256 for: $file" >&2
        return 4
    fi

    if [[ "$actual" != "$expected" ]]; then
        echo "ERROR: sha256 mismatch for $file" >&2
        echo "  expected: $expected" >&2
        echo "  actual:   $actual" >&2
        return 1
    fi

    return 0
}

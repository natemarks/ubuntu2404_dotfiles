#!/usr/bin/env bash
eval "$(zoxide init bash)"
zi() {
 local dir
 dir=$(zoxide query -l | fzf) && z "$dir"
}

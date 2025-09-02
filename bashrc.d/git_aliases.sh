#!/usr/bin/env bash
alias git_rollback_to_remote='git reset --hard @{u}' # reverts the local copy of the branch to match the upstream
alias git_rm_ignored='git rm -r --cached . && git add . && git commit -m "purged files based on new .gitignore fix"'
alias gmm='git branch -m master main' # rename master branch to main
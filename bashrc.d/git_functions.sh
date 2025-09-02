#!/usr/bin/env bash
# shellcheck disable=SC2148
# gwbdiff -  git working - branch diff
# compare file in git working directory to the same file in another branch
# write the branch file to a temp file
function gwbdiff() {
  local T_FILE
  local BRANCH
  local W_FILE
  T_FILE="$(mktemp)"
  BRANCH="${1}"
  W_FILE="${2}"
  git show "${BRANCH}":"${W_FILE}" > "${T_FILE}"
  printf "Comparing %s to %s" "${W_FILE}" "${T_FILE}"
  vim -d "${W_FILE}" "${T_FILE}"
}

function git_diff() {
  git diff --word-diff=color --word-diff-regex=. "$1" "$2"
}

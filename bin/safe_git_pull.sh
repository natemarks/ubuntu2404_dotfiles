#!/usr/bin/env bash
if git diff --quiet && git diff --cached --quiet; then
  current_branch=$(git branch --show-current)
  if [ "$current_branch" = "main" ]; then
    git branch --set-upstream-to=origin/main main
  fi
  git pull
else
  echo "Repo has local changes; skipping pull"
fi

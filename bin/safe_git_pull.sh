#!/usr/bin/env bash
if git diff --quiet && git diff --cached --quiet; then
  git pull
else
  echo "Repo has local changes; skipping pull"
fi

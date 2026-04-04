#!/usr/bin/env bash

# Check if the TMUX environment variable is set
if [ -n "$TMUX" ]; then
    echo "You are currently in a tmux session."
    exit 0
fi

SESSION_NAME="opencode"

# Check if the tmux session exists
if ! tmux has-session -t $SESSION_NAME >/dev/null 2>&1; then
  # If session doesn't exist, create a new one
  tmux new-session -d -s $SESSION_NAME -n gov-oc -c ~/projects/aws-governance/
  tmux new-window -t $SESSION_NAME -n gov-nv -c ~/projects/aws-governance/ "nv"
  tmux new-window -t $SESSION_NAME -n nplza-oc -c ~/projects/non-prod-aws-accelerator-config/
  tmux new-window -t $SESSION_NAME -n nplza-nv -c ~/projects/non-prod-aws-accelerator-config/ "nv"
  tmux new-window -t $SESSION_NAME -n lza-oc -c ~/projects/prod-ImprLza01-config/
  tmux new-window -t $SESSION_NAME -n lza-nv -c ~/projects/prod-ImprLza01-config/ "nv"
fi

# Attach to the session
tmux attach-session -t $SESSION_NAME


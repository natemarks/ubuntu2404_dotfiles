#!/usr/bin/env bash
# Some tmux-related shell aliases

# Attaches tmux to the last session; creates a new session if none exists.
alias tt='tmux attach || tmux new-session'

# Attaches tmux to a session (example: ta portal)
alias ta='tmux attach -t'

# Creates a new session
alias tn='tmux new-session'

# Lists all ongoing sessions
alias tl='tmux list-sessions'

# Interactive session selector using sesh and fzf
function t() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c -z | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

# Setup dev environment with neovim and claude windows
function dev_setup() {
  # Check if we're inside tmux
  if [ -z "$TMUX" ]; then
    echo "Error: Must be run from inside a tmux session"
    return 1
  fi

  # Rename current window to 'editor' and start neovim
  tmux rename-window 'editor'
  tmux send-keys 'nv' C-m

  # Create a new window named 'claude' and start claude
  tmux new-window -n 'claude'
  tmux send-keys 'claude' C-m

  # Switch back to editor window
  tmux select-window -t 'editor'
}
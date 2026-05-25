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

# Interactive session selector using sesh and fzf with project directory picker
function t() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list | fzf --ansi --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ' \
      --header '  ^a all ^t tmux ^g configs ^x zoxide ^f projects' \
      --bind 'tab:down,btab:up' \
      --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
      --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
      --bind 'ctrl-f:change-prompt(🚀  )+reload(find ~/projects -mindepth 1 -maxdepth 1 -type d)')
    [[ -z "$session" ]] && return

    # Use --switch flag if we're inside tmux, otherwise attach normally
    if [[ -n "$TMUX" ]]; then
      sesh connect --switch "$session"
    else
      sesh connect "$session"
    fi
  }
}

# Setup dev environment with neovim and claude windows
function dev_setup() {
  # Check if we're inside tmux
  if [ -z "$TMUX" ]; then
    echo "Error: Must be run from inside a tmux session"
    return 1
  fi

  # Get the current session name
  local session_name
  session_name=$(tmux display-message -p '#S')

  # Rename current window to 'editor' and start neovim
  tmux rename-window -t "${session_name}:0" 'editor'
  tmux send-keys -t "${session_name}:editor" 'nv' C-m

  # Create a new window named 'claude' and start claude
  tmux new-window -t "${session_name}" -n 'claude'
  tmux send-keys -t "${session_name}:claude" 'claude' C-m

  # Switch back to editor window
  tmux select-window -t "${session_name}:editor"
}
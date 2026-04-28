# ubuntu2404_dotfiles

Personal dotfiles repository for Ubuntu 24.04 LTS system configuration. This repository manages shell configurations, utility scripts, tool installations, and development environment setup through a Make-based build system.

## Quick Start

### First Time Setup (New Machine)

```bash
# Clone this repository
git clone <repo-url> ~/projects/ubuntu2404_dotfiles
cd ~/projects/ubuntu2404_dotfiles

# Install all required packages and configure everything
make all
```

### Syncing Configuration (Existing Machine)

```bash
# Pull latest changes
cd ~/projects/ubuntu2404_dotfiles
git pull

# Re-run relevant target to apply changes
make bash      # Re-sync bash configuration
make gitconfig # Re-sync git configuration
# ... or other specific targets
```

## Makefile Targets

Run `make help` to see all available targets with descriptions.

### Core Setup Targets

- **`make all`** - Complete setup: installs packages, configures bash, git, ssh, kubectl, pyenv, lazygit, golang, docker, nodejs
- **`make packages`** - Install all required apt packages (git, tmux, fzf, ripgrep, docker, etc.)
- **`make home`** - Configure home directory structure (`~/bin`, `~/tmp`, `~/projects`)

### Shell Configuration

- **`make bash`** - Configure bash environment (symlink all `bashrc.d/` modules to `~/bashrc.d/`)
- **`make bin`** - Symlink utility scripts from `bin/` to `~/bin` (encryption, AWS helpers, git utilities)
- **`make powerline`** - Install and configure powerline themes and colorschemes

### Tool Configuration

- **`make gitconfig`** - Symlink git configuration to `~/.gitconfig`
- **`make ssh-config`** - Symlink SSH configuration to `~/.ssh/config`
- **`make config_tmux`** - Configure tmux (symlink `tmux.conf`, install tpm plugins)
- **`make neovim`** - Install neovim and copy configuration to `~/.config/nvim`
- **`make $(HOME)/.config/sesh/sesh.toml`** - Configure sesh session manager

### Development Tools Installation

- **`make nodejs`** - Install Node.js (version 22.x)
- **`make pyenv`** - Install pyenv (Python version manager)
- **`make golang`** - Install Go
- **`make docker`** - Install Docker
- **`make kubectl`** - Install kubectl
- **`make gh`** - Install GitHub CLI
- **`make lazygit`** - Install lazygit
- **`make ec2list`** - Install ec2list tool
- **`make aws_cdk`** - Install AWS CDK (requires nodejs)

### Validation & Testing

- **`make shellcheck`** - Run shellcheck on all shell scripts (mandatory before committing changes)

### Cleanup Targets

- **`make rm-bash`** - Remove bash configuration before replacing
- **`make rm-gitconfig`** - Remove git configuration before replacing
- **`make rm-ssh-config`** - Remove SSH configuration before replacing
- **`make rm-powerline`** - Remove powerline configuration before replacing
- **`make rm-sesh`** - Remove sesh configuration before replacing
- **`make delete_neovim`** - Delete neovim configuration
- **`make reset_neovim_config`** - Delete and re-copy neovim configuration
- **`make undo_edits`** - Reset repository to HEAD and clean untracked files
- **`make remove-all`** - ⚠️ **DANGEROUS**: Remove all configurations (use with extreme caution)

## Repository Structure

```
├── bashrc.d/          # Shell configuration modules (aliases, functions, tool configs)
├── bin/               # Utility scripts (encryption, AWS helpers, git utilities)
├── scripts/           # Installation scripts for external tools
├── awscli/            # AWS CLI configuration
├── ssh/               # SSH configuration
├── tmux/              # Tmux configuration
├── sesh/              # Sesh session manager configuration
├── powerline/         # Powerline themes and colorschemes
├── neovim/            # Neovim configuration (from separate repo)
├── Makefile           # Build system and installation orchestration
├── gitconfig          # Git configuration and aliases
├── bashrc.local       # Bash entry point (sources bashrc.d/ modules)
├── CLAUDE.md          # Guide for Claude Code AI assistant
└── README.md          # This file
```

## How It Works

This repository uses a **symlink-based configuration pattern**:

1. Configuration files live in this repository
2. Makefile targets create symlinks from the repo to your `$HOME` directory
3. You edit files in the repo, test them, and commit changes
4. Other machines pull changes and re-run `make` targets to sync

### Example: Bash Configuration

```bash
# The Makefile creates these symlinks:
~/bashrc.d/aliases.sh -> ~/projects/ubuntu2404_dotfiles/bashrc.d/aliases.sh
~/bashrc.d/git_functions.sh -> ~/projects/ubuntu2404_dotfiles/bashrc.d/git_functions.sh
# ... and so on for all bashrc.d/ modules

# Your ~/.bashrc sources ~/.bashrc.local
# ~/.bashrc.local sources all ~/bashrc.d/*.sh files
# So all your shell configuration is loaded automatically
```

## Making Changes

### Editing Shell Configuration

1. Edit files in `~/projects/ubuntu2404_dotfiles/bashrc.d/`
2. Test changes (source in current shell or open new shell)
3. Run `make shellcheck` to validate
4. Commit changes

### Adding New Aliases or Functions

1. Edit the appropriate file in `bashrc.d/` (e.g., `bashrc.d/git_aliases.sh`)
2. Or create a new file: `bashrc.d/newtool_aliases.sh`
3. If new file, add symlink command to `bash` target in Makefile
4. Run `make shellcheck`
5. Run `make bash` to create symlinks
6. Test in new shell: `bash -l`

### Adding New Utility Scripts

1. Create script in `bin/` directory with `#!/usr/bin/env bash` shebang
2. Make executable: `chmod +x bin/scriptname.sh`
3. Add symlink command to `bin` target in Makefile
4. Run `make shellcheck`
5. Run `make bin` to create symlink
6. Test: `~/bin/scriptname.sh`

## Testing Changes

### Before Committing

**Mandatory:**
- Run `make shellcheck` on any modified shell scripts
- Verify scripts pass shellcheck with no errors

**Recommended:**
- Test bash changes in a new shell session: `bash -l`
- Verify symlinks created correctly: `ls -la ~/target`
- Test affected tools still work (tmux, git, fzf, etc.)

### Critical Components

These tools form the core workflow and should be tested carefully after changes:
- **tmux** + **sesh** + **zoxide** + **fzf** (primary working environment)
- **powerline** (shell prompt)
- **git** aliases and functions
- **AWS** tools and configurations

## Important Notes

### Security

- Never commit credentials, tokens, or sensitive information
- Files with `.gpg` extension are encrypted and safe to commit
- AWS credentials should be in `~/.aws/credentials` (NOT in this repo)

### Platform

- This configuration is **Ubuntu 24.04 specific**
- Not designed for cross-platform compatibility
- Uses bash (not zsh or other shells)

### Neovim

- Neovim configuration is managed in a separate repository
- It's copied (not symlinked) to `~/.config/nvim`
- Use `make reset_neovim_config` to update from this repo

## Getting Help

- Read `LOG.md` for historical context and notes
- See `CLAUDE.md` for detailed technical documentation
- Tool-specific READMEs: `NEOVIM_README.md`, `POWERLINE_README.md`, `tmux/README.md`
- Run `make help` to see all available targets

## Common Workflows

### Set up a brand new Ubuntu 24.04 machine

```bash
git clone <repo-url> ~/projects/ubuntu2404_dotfiles
cd ~/projects/ubuntu2404_dotfiles
make all
```

### Sync changes to existing machine

```bash
cd ~/projects/ubuntu2404_dotfiles
git pull
make bash        # if bashrc.d/ changed
make gitconfig   # if gitconfig changed
# ... or other relevant targets
```

### Add a new bash alias

```bash
# Edit file
vim ~/projects/ubuntu2404_dotfiles/bashrc.d/git_aliases.sh

# Test in new shell
bash -l

# Validate
make shellcheck

# Commit
git add bashrc.d/git_aliases.sh
git commit -m "Add new git alias"
```

### Update tool installation script

```bash
# Edit script
vim ~/projects/ubuntu2404_dotfiles/scripts/install_kubectl.sh

# Validate
make shellcheck

# Test installation
make kubectl

# Commit
git add scripts/install_kubectl.sh
git commit -m "Update kubectl installation"
```

## Known Issues

1. **Direction keys in Claude Code** - Arrow keys may return raw characters. Workaround: `export TERM=xterm-256color && stty sane`
2. See `CLAUDE.md` for more details on known issues and workarounds

## License

Personal configuration repository. Use at your own risk.

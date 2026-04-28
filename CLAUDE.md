# CLAUDE.md

This file provides guidance to Claude Code when working with this dotfiles repository.

## Repository Overview

This is a personal Ubuntu 24.04 dotfiles repository used to configure and maintain consistent development environments across multiple machines. The repository manages shell configurations, utility scripts, tool installations, and system-wide settings through a Make-based build system that creates symlinks from the repository to `$HOME`.

**Primary Use Cases:**
- Setting up brand new Ubuntu 24.04 machines from scratch
- Syncing configuration changes across multiple existing machines
- Making incremental configuration changes and testing them
- Maintaining consistent development environments

**Primary User:** Single user (personal configuration repository)

## Repository Structure

```
├── bashrc.d/          Shell configuration modules (aliases, functions, tool-specific configs)
├── bin/               Utility scripts (encryption, AWS helpers, git utilities)
├── scripts/           Installation scripts for external tools (neovim, kubectl, docker, etc.)
├── awscli/            AWS CLI configuration files
├── ssh/               SSH configuration
├── tmux/              Tmux configuration and plugins
├── sesh/              Sesh session manager configuration
├── powerline/         Powerline themes and colorschemes
├── neovim/            Neovim configuration (from separate repo - DO NOT MODIFY)
├── Makefile           Orchestrates installation and symlinking
├── gitconfig          Git configuration
└── bashrc.local       Entry point that sources bashrc.d/ modules
```

## Technology Stack

### Core Technologies
- **Shell**: Bash (primary and default shell)
- **OS**: Ubuntu 24.04 LTS (this configuration is NOT cross-platform)
- **Package Manager**: apt
- **Build System**: GNU Make (orchestrates configuration deployment)

### Critical Workflow Tools
These tools form the core working environment and should be handled with extreme care:

- **tmux** - Terminal multiplexer (with tmux-resurrect and tmux-continuum plugins)
- **sesh** - Session manager (integrates with tmux)
- **zoxide** - Smart directory jumper
- **fzf** - Fuzzy finder (integrates with bash, tmux, and other tools)
- **powerline** - Shell prompt customization (critical visual component)
- **neovim** - Primary editor (config managed in separate repo)

### Development Tools
- **Languages**: Python (pyenv), Go, Rust, Node.js
- **Cloud/Infrastructure**: AWS CLI, kubectl, Docker
- **IaC Tools**: Terraform, Terragrunt, Packer, AWS CDK
- **Version Control**: git with extensive aliases and functions

### Build & Validation Tools
- **Build Tool**: GNU Make
- **Linting**: shellcheck (mandatory for all shell scripts)
- **Formatting**: shfmt (available but not enforced in build)
- **Encryption**: GPG (for sensitive configuration files)

### Build Commands
```bash
make help              # Show all available targets with descriptions
make packages          # Install all required apt packages
make all              # Full setup: packages, bin, powerline, bash, gitconfig, ssh-config, etc.
make bash             # Configure bash environment (symlink bashrc.d/ modules)
make bin              # Symlink utility scripts to ~/bin
make gitconfig        # Symlink git configuration
make shellcheck       # Run shellcheck on all shell scripts (MANDATORY before commits)
```

## Architecture

### System Design

This repository uses a **symlink-based configuration management** pattern:
1. All configuration files live in the repository
2. Makefile targets create symlinks from repo → `$HOME` directories
3. Changes are made in the repo, tested, then committed
4. Other machines pull changes and re-run relevant `make` targets

**Symlink Strategy:**
- Individual utility scripts: `~/bin/script` → `repo/bin/script`
- Shell modules: `~/bashrc.d/module.sh` → `repo/bashrc.d/module.sh`
- Tool configs: `~/.gitconfig` → `repo/gitconfig`
- `~/.bashrc.local` sources all `~/bashrc.d/*.sh` files

**Special Case - Neovim:**
- Neovim config is **copied** (not symlinked) to `~/.config/nvim`
- Managed in a separate repository
- DO NOT MODIFY neovim configuration in this repo

### Configuration Loading Order

1. System bash reads `~/.bashrc`
2. `~/.bashrc` sources `~/.bashrc.local` (symlinked from this repo)
3. `~/.bashrc.local` sources all `~/bashrc.d/*.sh` files
4. Each module in `bashrc.d/` provides specific functionality:
   - PATH modifications
   - Aliases and functions
   - Tool-specific configurations
   - Powerline setup

### Integration Points

**Critical Integration (tmux + sesh + zoxide + fzf):**
These tools work together to create the primary workflow environment. Changes to any of these configurations should be made cautiously and tested thoroughly.

**External Services:**
- AWS (via AWS CLI, requires credentials)
- GitHub (via gh CLI)
- Docker registries
- Kubernetes clusters

**Encrypted Configurations:**
- `.gpg` files contain sensitive/work-specific configurations
- Never decrypt, read, or modify encrypted files
- Encryption/decryption scripts in `bin/encrypt` and `bin/decrypt`

## Code Standards

### Shell Script Standards

**Shebang:**
```bash
#!/usr/bin/env bash
```
Always use this shebang for all shell scripts. NEVER use `#!/bin/bash` or POSIX `#!/bin/sh`.

**File Extensions:**
- Always use `.sh` extension for shell scripts
- Exception: utility scripts in `bin/` may omit extension (e.g., `encrypt`, `decrypt`)

**Bash Features:**
- Can use bash-specific features (arrays, `[[`, `$()`, etc.)
- Not restricted to POSIX sh compatibility
- Prefer modern bash idioms

**Error Handling:**
- Consider using `set -e` for scripts that should fail fast
- Consider using `set -u` to catch undefined variables
- Add error messages with context
- Return appropriate exit codes

**shellcheck Compliance:**
- **MANDATORY** for all shell scripts
- Must pass before committing any shell script changes
- Run via `make shellcheck`
- Use `# shellcheck disable=SCXXXX` sparingly and only when necessary
- Exception: `ohmyzsh_git_aliases.sh` is skipped (external source)

### Naming Conventions

**Functions:**
- `snake_case` for function names
- Descriptive names that indicate purpose
- Example: `fzf_completion()`, `safe_git_pull()`

**Variables:**
- `UPPER_SNAKE_CASE` for constants and environment variables
- `snake_case` for local variables
- Example: `POWERLINE=/path`, `local os_type`

**Files:**
- `kebab-case` or `snake_case` for file names
- Use `.sh` extension for shell scripts
- Descriptive names indicating purpose
- Example: `install_kubectl.sh`, `git_aliases.sh`

**Aliases:**
- Short, memorable names
- Keep small and focused (one alias = one purpose)
- Document complex aliases with comments
- Organized by tool/category in separate files

### Code Organization

**Shell Modules (`bashrc.d/`):**
- One file per tool or category
- Files sourced automatically by `~/.bashrc.local`
- Naming pattern: `<tool>_<type>.sh`
  - `*_aliases.sh` - Alias definitions
  - `*_functions.sh` - Function definitions
  - `*.sh` - Tool configuration/setup

**Utility Scripts (`bin/`):**
- Self-contained executable scripts
- Include shebang and error handling
- Document usage in comments at top of file
- Symlinked to `~/bin` for PATH access

**Installation Scripts (`scripts/`):**
- Install specific external tools
- Idempotent (can run multiple times safely)
- Check if tool already installed before installing
- Clean up temporary files

### Makefile Conventions

**Target Naming:**
- `snake_case` for target names
- Descriptive of what the target does
- Targets that create files should be named after the file

**Documentation:**
- All targets MUST have `##` comments for `make help`
- Format: `target: ## Description of what this target does`
- Help text should be clear and actionable

**Idempotency:**
- **PRIORITY**: All targets must be idempotent
- Can be run multiple times without causing issues
- Use `-` prefix for commands that may fail (e.g., `rm -f`)
- Check for existence before creating/linking
- Remove old symlinks before creating new ones

**Dependencies:**
- Declare dependencies between targets explicitly
- Example: `aws_cdk: nodejs` (AWS CDK requires Node.js)
- Use `.PHONY` for targets that don't create files

**Pattern:**
```makefile
target: dependency ## Description
	$(MKDIR) $(HOME)/directory
	-rm -f $(HOME)/target
	$(LN) $(PRJ)/source $(HOME)/target
```

## Security Requirements

### Sensitive Information - NEVER COMMIT

**Absolutely Never Commit:**
- AWS credentials, access keys, secret keys, tokens
- SSH private keys
- API tokens or passwords
- Any file containing authentication credentials
- Decrypted versions of `.gpg` files

**Encrypted Files:**
- Files with `.gpg` extension are encrypted and safe to commit
- **NEVER decrypt, read, or modify `.gpg` files**
- These contain work-specific or sensitive configurations
- User manages encryption/decryption manually

### Secrets Management
- Sensitive configs stored in `.gpg` encrypted files
- Encryption scripts: `bin/encrypt` and `bin/decrypt`
- Never commit decrypted sensitive files
- Machine-specific overrides go in `~/.bashrc.local` (user-managed)

### AWS Configuration
- `awscli/config` is symlinked but should NOT contain credentials
- AWS credentials stored in `~/.aws/credentials` (NOT in this repo)
- Be cautious about changes to AWS configuration

## Design Patterns

### Preferred Patterns

**Symlink-Based Configuration:**
- Store source in repo
- Create symlinks from repo to `$HOME`
- Allows easy version control and syncing
- Pattern preserved throughout this repo

**Modular Shell Configuration:**
- Split bash config into focused modules in `bashrc.d/`
- One file per tool or category
- Automatically sourced by `~/.bashrc.local`
- Easy to add/remove/disable individual modules

**Idempotent Installation:**
- All Makefile targets can be run multiple times
- Check for existence before creating
- Remove before linking/creating
- Safe to re-run after git pull

**Small, Focused Functions:**
- Keep aliases and functions small and focused
- One function = one purpose
- Compose larger workflows from smaller functions
- Easy to understand and maintain

### Patterns to Avoid

**Inline Credentials:**
Never hardcode credentials in scripts. Use environment variables or credential files outside the repo.

**Non-Idempotent Operations:**
Avoid operations that fail or cause problems when run twice. Always design for multiple executions.

**Monolithic Configuration Files:**
Don't create large, multi-purpose configuration files. Split into focused modules.

**Platform Assumptions:**
This repo is Ubuntu 24.04 specific. Don't add cross-platform logic unless explicitly needed.

### Bash Idioms

**Command Substitution:**
```bash
# Prefer $() over backticks
result=$(command)
```

**Conditionals:**
```bash
# Use [[ ]] for bash conditionals (not [ ])
if [[ "$var" == "value" ]]; then
    # ...
fi
```

**Error Checking:**
```bash
# Check command success
if ! command; then
    echo "Error: command failed" >&2
    exit 1
fi
```

## Testing Strategy

### Testing Approach
- **Test in place**: Edit files in the repo, source/test them in current shell
- **New shell test**: Open a new bash session to test bashrc changes
- **Re-run make targets**: After git pull, re-run relevant make target to apply changes

### Validation Before Committing

**MANDATORY:**
1. Run `make shellcheck` on all modified shell scripts
2. Verify shellcheck passes with no errors
3. Test changes in a new shell session (for bashrc changes)
4. Verify idempotency (run make target twice, check for errors)

**Recommended:**
- Test symlinks were created correctly: `ls -la ~/target`
- Test aliases/functions work in new shell: `bash -l`
- For critical tools (tmux, powerline, fzf), verify they still work
- Check for error messages in new shell startup

### Testing Critical Components

**Tmux/Sesh/Zoxide/fzf:**
These form the primary working environment. Test thoroughly:
- Open new tmux session
- Test session switching with sesh
- Test directory jumping with zoxide
- Test fuzzy finding with fzf

**Powerline:**
Critical visual component. After changes:
- Open new terminal
- Verify prompt displays correctly
- Check colors and formatting
- Test in tmux session

**AWS Tools:**
Be careful with changes. Verify:
- AWS CLI commands still work
- kubectl can still connect to clusters
- Docker commands function properly

### When Claude Should Recommend Testing

Claude should suggest specific validation steps after:
- Modifying any `bashrc.d/*.sh` files: "Test in a new bash session"
- Changing Makefile targets: "Run the target twice to verify idempotency"
- Updating shell scripts: "Run `make shellcheck` to validate"
- Modifying tmux/powerline/fzf configs: "Start a new tmux session to test"

## Workflows

### Development Workflow

1. **Edit files directly** in `~/projects/ubuntu2404_dotfiles/`
2. **Test changes** in current or new shell session
3. **Run shellcheck** if shell scripts were modified: `make shellcheck`
4. **Verify functionality** for affected tools
5. **Commit changes** (user commits, Claude does NOT commit)

### Git Workflow

**Branching Strategy:**
- Work directly on `main` branch
- No feature branches typically used
- Fast, iterative changes

**Commit Messages:**
- User creates commits (Claude never commits)
- No specific format required
- Should be descriptive of changes

**Pre-commit:**
- No automated pre-commit hooks configured
- Manual validation required (shellcheck, testing)

### Syncing Configuration to Other Machines

1. On target machine: `cd ~/projects/ubuntu2404_dotfiles`
2. Pull latest changes: `git pull`
3. Re-run relevant make target(s): `make bash` or `make gitconfig`, etc.
4. Open new shell session to load changes
5. Verify functionality

**Caution:**
Be aware that syncing changes can affect active shell sessions. Recommend opening a new session to test rather than sourcing in the current session.

### Adding New Configuration

**New Shell Module:**
1. Create file in `bashrc.d/` with appropriate name
2. Add shebang: `#!/usr/bin/env bash`
3. Add aliases/functions/configuration
4. Add symlink command to `bash` target in Makefile
5. Run `make shellcheck`
6. Run `make bash` to create symlink
7. Test in new shell session

**New Utility Script:**
1. Create script in `bin/` directory
2. Add shebang: `#!/usr/bin/env bash`
3. Make executable: `chmod +x bin/scriptname`
4. Add symlink command to `bin` target in Makefile
5. Run `make shellcheck`
6. Run `make bin` to create symlink
7. Test script: `~/bin/scriptname`

**New Installation Script:**
1. Create script in `scripts/` directory
2. Add shebang: `#!/usr/bin/env bash`
3. Make idempotent (check if already installed)
4. Create new Makefile target
5. Run `make shellcheck`
6. Test the new target

**New Tool Configuration:**
1. Create directory for tool: `mkdir toolname/`
2. Add configuration files
3. Create Makefile target to symlink configs
4. Document in README.md
5. Test configuration

### Rollback Strategy

If changes break something:
1. **Revert in Git**: User runs `git revert` or `git reset`
2. **Re-run make target**: Apply previous working configuration
3. **Restore from backup**: If make created `.backup` files
4. **Manual restore**: Remove symlinks, restore original files

## Known Issues

### Issue 1: Direction Keys in Claude Code

**Symptom:** Direction keys (arrow keys) return raw escape characters instead of moving cursor when using Claude Code terminal.

**Root Cause:** Terminal mode/TERM environment variable issue.

**Workaround:**
```bash
# 1. Ensure real terminal
tty

# 2. Fix TERM
export TERM=xterm-256color

# 3. Reset terminal modes
stty sane
```

**Status:** Workaround available, permanent fix TBD.

**Impact:** Affects usability of Claude Code terminal, but workaround resolves it.

### Issue 2: fzf key-bindings path (FIXED)

**Symptom:** Error on bash startup: `/usr/share/doc/fzf/examples/key-bindings.bash: No such file or directory`

**Root Cause:** Incorrect path in `bashrc.d/fzf.sh` - files are in `/usr/share/doc/fzf/` not `examples/` subdirectory.

**Resolution:** Fixed in `bashrc.d/fzf.sh` to use correct hardcoded paths for Ubuntu 24.04.

**Status:** ✅ RESOLVED

## Guidelines for Claude Code

### What Claude Should NEVER Do

**CRITICAL - NEVER:**
- ❌ Run `make remove-all` (destroys all configurations)
- ❌ Modify or decrypt `.gpg` encrypted files
- ❌ Commit changes (user commits manually)
- ❌ Run targets that could break an active session without warning
- ❌ Modify neovim configuration in `neovim/` directory
- ❌ Commit credentials, tokens, or sensitive information
- ❌ Skip shellcheck validation for shell scripts
- ❌ Make changes to encrypted files
- ❌ Assume cross-platform compatibility (Ubuntu 24.04 only)

### What Claude Should ALWAYS Do

**MANDATORY:**
- ✅ Run `make shellcheck` after modifying any shell script
- ✅ Suggest specific validation steps for testing changes
- ✅ Check for potential symlink conflicts before running make targets
- ✅ Verify idempotency of new or modified Makefile targets
- ✅ Preserve the symlink pattern for new configurations
- ✅ Use `#!/usr/bin/env bash` shebang for all shell scripts
- ✅ Use `.sh` extension for all shell scripts
- ✅ Keep aliases and functions small and focused
- ✅ Document why when making non-obvious changes

### What Claude Should Be Cautious About

**Handle with Care:**
- ⚠️ Changes to `bashrc.d/` files (affects shell sessions)
- ⚠️ Powerline configuration (critical visual component)
- ⚠️ Tmux/sesh/zoxide/fzf configurations (primary workflow)
- ⚠️ AWS tool configurations
- ⚠️ Installation scripts that download external tools (verify URLs/versions)
- ⚠️ Changes that affect active sessions (recommend testing in new session)

**Be Verbose About:**
- Changes to external dependency installation scripts
- Version updates for external tools
- Changes to critical workflow tools
- Suggest thorough testing procedures

### Common Tasks Claude Will Help With

**Primary Use Cases:**
1. **Adding new aliases or functions**
   - Create in appropriate `bashrc.d/*.sh` file
   - Add symlink to Makefile `bash` target
   - Run shellcheck
   - Suggest testing in new shell

2. **Updating installation scripts**
   - Modify scripts in `scripts/` directory
   - Verify idempotency
   - Run shellcheck
   - Test installation process
   - Be verbose about changes to external dependencies

3. **Debugging shell configuration issues**
   - Read relevant `bashrc.d/` files
   - Check symlinks: `ls -la ~/bashrc.d/`
   - Test in new shell session
   - Review error messages from shell startup

4. **Adding new tool configurations**
   - Create directory for tool configs
   - Create Makefile target with symlinks
   - Verify idempotency
   - Test configuration
   - Update documentation

### Specialized Workflows

**When Modifying Shell Scripts:**
```bash
# 1. Edit the script in the repo
# 2. Run shellcheck
make shellcheck
# 3. If script is in bashrc.d/, test in new shell
bash -l
# 4. Verify functionality
```

**When Adding New Makefile Targets:**
```makefile
# 1. Create target with ## comment
# 2. Ensure idempotency (use -rm before ln)
# 3. Test target twice to verify idempotency
make newtarget
make newtarget  # Should not error
# 4. Verify symlinks created correctly
ls -la ~/target/location
```

**When Syncing to Another Machine:**
```bash
# 1. Pull latest changes
git pull
# 2. Re-run relevant target
make bash  # or other target
# 3. Open new shell to test
bash -l
```

### Communication Style with User

**When Making Changes:**
- State what you're about to do before doing it
- Explain why the change is structured the way it is
- Suggest testing procedures after changes
- Be explicit about validation requirements

**After Making Changes:**
- Summarize what was changed
- List validation steps to perform
- Highlight any cautions or considerations
- Suggest testing in new shell if bashrc modified

**When Uncertain:**
- Ask before making changes to critical components
- Verify intent before modifying powerline/tmux/fzf configs
- Confirm before running targets that might affect active sessions

## Documentation

### Documentation Locations

- **README.md**: User-facing documentation of Makefile targets and usage
- **CLAUDE.md**: This file - comprehensive guide for Claude Code
- **LOG.md**: Historical log of changes and notes
- **NEOVIM_README.md**: Neovim-specific documentation
- **POWERLINE_README.md**: Powerline-specific documentation
- **tmux/README.md**: Tmux-specific documentation

### Keeping Documentation Updated

When making significant changes:
- Update CLAUDE.md if new patterns or standards are established
- Update README.md if new Makefile targets are added
- Keep documentation concise and focused

### Philosophy

- CLAUDE.md is the source of truth for how Claude should work with this repo
- README.md is the source of truth for users
- Code should be self-documenting where possible
- Comments should explain "why" not "what"

## References

### External Dependencies

**Package Sources:**
- Ubuntu apt repositories (see `make packages`)
- Node.js setup script: https://deb.nodesource.com/setup_22.x
- Spotify repository: http://repository.spotify.com
- Various GitHub releases (gh CLI, kubectl, neovim, lazygit, etc.)

**Tool Documentation:**
- tmux: https://github.com/tmux/tmux
- tmux plugins: https://github.com/tmux-plugins/tpm
- sesh: https://github.com/joshmedeski/sesh
- zoxide: https://github.com/ajeetdsouza/zoxide
- fzf: https://github.com/junegunn/fzf
- powerline: https://powerline.readthedocs.io/

### Internal Resources

**Key Configuration Files:**
- `Makefile` - Build system and installation orchestration
- `bashrc.local` - Entry point for bash configuration
- `gitconfig` - Git configuration and aliases
- `.gitignore` - Files excluded from version control

**Installation Scripts:**
- `scripts/install_*.sh` - Tool installation scripts
- `bin/*` - Utility scripts for daily use

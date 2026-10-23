# Neovim

The config lives in a separate repo, [natemarks/kickstart.nvim](https://github.com/natemarks/kickstart.nvim), cloned to `~/.config/nvim`. It targets Neovim 0.12 (nvim-treesitter `main`, mason-lspconfig v2); see `UPDATE_NEOVIM.md` for the migration.

## Install

```bash
make neovim
```

- installs the tree-sitter CLI (latest release) to `~/local/tree-sitter-<version>`, linked at `~/bin/tree-sitter`
- installs Node.js if `node` is missing (mason installs pyright with npm)
- installs the Neovim version pinned in `scripts/install_neovim.sh` to `~/local/nvim-<version>`, linked at `~/bin/nv`
- clones kickstart.nvim to `~/.config/nvim` if it isn't there

Start `nvim` once and wait: lazy.nvim installs plugins, nvim-treesitter builds parsers, mason installs language servers. Then run `:checkhealth`.

## Versions

Multiple versions sit side by side in `~/local/nvim-<version>`. `bashrc.d/neovim.sh` puts the one `~/bin/nv` points at on `PATH`.

```bash
nv-switch --list        # installed versions
nv-switch 0.12.6        # activate one (open a new shell afterwards)
make uninstall_neovim VERSION=0.12.3
```

Neovim stays pinned: bump `NVIM_VERSION` and `NVIM_SHA256SUM` in `scripts/install_neovim.sh` deliberately, then run `make neovim`.

## Config

```bash
make reset_neovim_config   # delete ~/.config/nvim and ~/.local/share/nvim, re-clone
make delete_neovim         # delete both without re-cloning
```

The clone comes from GitHub, so push kickstart.nvim changes before re-cloning.

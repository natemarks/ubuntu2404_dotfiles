# Update Neovim to 0.12 (Ubuntu 26.04)

Migrate the Neovim setup to Neovim 0.12.x and the current plugin APIs. Two repos are involved:

- **dotfiles**: `~/projects/ubuntu2404_dotfiles` (installs Neovim and the tree-sitter CLI)
- **kickstart**: `~/projects/kickstart.nvim` (the Neovim config, deployed to `~/.config/nvim`)

Work through the steps in order; each ends on a **done when** check. The user commits; leave both repos with uncommitted changes for review.

## Status (2026-10-23)

Steps 2–8 are **applied and verified** on the first machine (isolated run under 0.12.6: all 14 parsers built, every LSP server installed, lua_ls/rust-analyzer settings applied, no stylua client, treesitter active on Python, `grr` mapped, `:checkhealth` clean). `telescope` references moved to `grr` (the user's choice for step 6.1). Also fixed: `scripts/install_neovim.sh` no longer symlinks the release's `share/nvim` over `~/.local/share/nvim` (Neovim's data dir), which broke fresh machines.

On another machine, once both repos are pushed and pulled, the work reduces to:

```bash
cd ~/projects/ubuntu2404_dotfiles
make packages
make neovim        # tree-sitter (latest), node if missing, nvim 0.12.6, clone kickstart.nvim
nvim               # first start: wait for lazy, parsers, and mason to finish; then :checkhealth
```

The steps below record what changed and why, and serve as the checklist if anything regresses.

## Why this is needed

Neovim 0.12.6 itself runs the kickstart config with no errors and a clean `:checkhealth vim.deprecated`. The breakage comes from **plugin drift**: `lazy-lock.json` is gitignored, so every deploy pulls the newest plugins, and two of them shipped incompatible rewrites.

| Symptom (observed on 0.12.6, Oct 2026) | Cause |
|---|---|
| Custom LSP settings silently ignored: lua_ls ran with lspconfig defaults, rust-analyzer lost clippy/allFeatures/procMacro settings | mason-lspconfig v2 removed the `handlers` option that `lua/custom/lsp/mason.lua` uses; v2 auto-enables servers with default configs |
| `stylua` attaches as an LSP client | mason-lspconfig v2 `automatic_enable` enables every installed server that has an lspconfig entry |
| No treesitter highlighting for Python; no parsers installed | nvim-treesitter's default branch is now `main`, a full rewrite that ignores `ensure_installed`, `highlight`, `indent`, `auto_install`, `parser_install_dir` |
| Parsers can't be built | nvim-treesitter `main` needs the `tree-sitter` CLI >= 0.26.1 and a C compiler; apt's `tree-sitter-cli` on 26.04 is 0.25.9 |

The `master` branch of nvim-treesitter is frozen and supports only Neovim 0.11, so pinning back is not an option: migrate to `main`.

## Already done in dotfiles (on the first machine)

These are committed from the first machine; pull them rather than redoing them:

- `scripts/install_neovim.sh` pinned to **0.12.6** with its sha256.
- `scripts/treesitter-cli.sh` rewritten: installs to `~/local/tree-sitter-<version>` (no sudo), links `~/bin/tree-sitter`, verifies sha256, detects x86_64/arm64. Pinned to 0.27.1.
- `make treesitter_cli` target added; `make neovim` depends on it.
- `make packages` fixed for 26.04 (`libimage-exiftool-perl`, `python3-venv`, `7zip`, `7zip-rar` replace packages missing on 26.04) and now includes `wl-clipboard`.

## Step 1: Prepare the machine

```bash
cd ~/projects/ubuntu2404_dotfiles && git pull
make packages nodejs        # nodejs: pyright installs via npm
```

**Done when:** `git log` shows the commits above, `gcc --version` and `node --version` succeed, and `lsb_release -ds` reports Ubuntu 26.04.

## Step 2: tree-sitter CLI tracks the latest release (dotfiles)

The user wants the latest tree-sitter, matching how `scripts/install_sesh.sh` tracks the latest sesh. Change `scripts/treesitter-cli.sh`:

- Default to the latest release; `TREESITTER_VERSION=x.y.z` in the environment pins one.
- Resolve the version and sha256 from the GitHub API, because tree-sitter publishes no checksums file:
  `curl -fsSL https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest | jq -r '.tag_name'`, and the asset's `.digest` field (`sha256:<hex>`) for `tree-sitter-linux-<x64|arm64>.gz`. For a pinned version use `/releases/tags/v<version>`.
- Remove the hardcoded `TREESITTER_SHA256` table; keep `check_sha256` from `scripts/helper.sh`.
- Keep the existing behaviour: skip the download when that version's binary exists, always relink `~/bin/tree-sitter`, print `--version`.

**Done when:** `make treesitter_cli` run twice installs then skips, `tree-sitter --version` reports the latest release (>= 0.26.1), and `shellcheck scripts/treesitter-cli.sh` reports nothing beyond the SC1091 info on `source helper.sh`.

## Step 3: Fix the neovim make targets (dotfiles)

`make neovim` currently installs, then runs `reset_neovim_config`, which deletes `~/.config/nvim` and `~/.local/share/nvim` and copies `$(PRJ)/neovim/*`, a directory that does not exist, so the target fails after wiping state. The real deploy is `scripts/nvim-clone.sh` (clones kickstart from GitHub; refuses to run if `~/.config/nvim` or `~/.local/share/nvim` exists).

- Make `neovim` depend on `treesitter_cli` and `nodejs`, run `scripts/install_neovim.sh`, then deploy with `scripts/nvim-clone.sh` when `~/.config/nvim` is absent.
- Point `reset_neovim_config` at `delete_neovim` + `scripts/nvim-clone.sh` instead of the missing `neovim/` copy.
- Every target keeps a `##` help comment and stays idempotent (see `CLAUDE.md`).
- Update `NEOVIM_README.md`: versions live in `~/local/nvim-<version>`, `~/bin/nv` selects the active one (`bin/nv-switch`), and the config targets 0.12.

**Done when:** `make -n neovim` shows install, tree-sitter, and clone steps with no reference to `$(PRJ)/neovim`; `make neovim` succeeds on a machine with no `~/.config/nvim` and succeeds again on the second run; `make shellcheck` exits 0.

## Step 4: Migrate nvim-treesitter to `main` (kickstart)

`main` only installs parsers and queries; Neovim does highlighting and indent.

`lua/custom/plugins/treesitter/init.lua`:

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false, -- main does not support lazy-loading
  build = ':TSUpdate',
  config = function()
    require('custom.plugins.treesitter.config').setup()
  end,
}
```

`lua/custom/plugins/treesitter/config.lua`: replace the `M.opts` table and the `ensure_python_parser_installed` workaround with:

```lua
local M = {}

-- go/rust/python are needed by neotest adapters and the LSP setup
M.parsers = { 'bash', 'c', 'diff', 'go', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query', 'rust', 'vim', 'vimdoc' }

function M.setup()
  local ts = require 'nvim-treesitter'
  ts.setup { install_dir = vim.fn.stdpath 'data' .. '/site' }

  if vim.fn.executable 'tree-sitter' == 1 then
    ts.install(M.parsers)
  else
    vim.schedule(function()
      vim.notify("nvim-treesitter: 'tree-sitter' CLI not found; run `make treesitter_cli` in the dotfiles repo", vim.log.levels.WARN)
    end)
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('custom-treesitter-start', { clear = true }),
    callback = function(args)
      if pcall(vim.treesitter.start, args.buf) then
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })
end

return M
```

The old ruby special-cases (`additional_vim_regex_highlighting`, indent disable) drop out: ruby is not in the parser list. Check the installed plugin's `README.md` (`~/.local/share/nvim/lazy/nvim-treesitter/README.md`) if any call above errors; it is the source of truth for the `main` API.

**Done when:** opening a `.py` file gives `vim.treesitter.highlighter.active[bufnr] ~= nil`, and `:checkhealth nvim-treesitter` shows the tree-sitter CLI found and the listed parsers installed.

## Step 5: Migrate to mason-lspconfig v2 (kickstart)

Replace the `handlers` block in `lua/custom/lsp/mason.lua`. Settings move to Neovim's native `vim.lsp.config`, which merges over nvim-lspconfig's `lsp/<name>.lua` defaults; mason-lspconfig only enables the listed servers.

```lua
local M = {}

function M.setup(servers, capabilities)
  require('mason').setup()

  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, require('custom.lsp.tools').get())
  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  vim.lsp.config('*', { capabilities = capabilities })
  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
  end

  require('mason-lspconfig').setup {
    -- only our servers; keeps tools like stylua from starting as LSP clients
    automatic_enable = vim.tbl_keys(servers),
  }
end

return M
```

`lua/custom/lsp/servers/*.lua` keep their shape (`{ name = { settings = ... } }`); no change needed there.

**Done when:** in a `.lua` buffer, `vim.lsp.get_clients()` lists `lua_ls` (and no `stylua`) and its `settings.Lua.completion.callSnippet == 'Replace'`; in a Rust project, `rust_analyzer`'s `settings['rust-analyzer'].checkOnSave.command == 'clippy'`.

## Step 6: Smaller kickstart fixes

Each is independent; apply all of them.

1. **`gr` keymap conflict.** Neovim 0.11+ ships default LSP maps under `gr` (`grn` rename, `gra` code action, `grr` references, `gri` implementation, `grt` type definition). The custom `gr` map (`lua/custom/lsp/core.lua`, `lua/custom/lsp/which_key.lua`) makes every `gr` wait `timeoutlen`. **Ask the user** which they want: move telescope references to `grr` (recommended; overrides the built-in with the telescope picker), or keep `gr` and delete the built-in `gr*` maps.
2. **Mason org rename.** `williamboman/mason.nvim` and `williamboman/mason-lspconfig.nvim` moved to `mason-org/*`: update `init.lua` and `lua/kickstart/plugins/debug.lua`. GitHub redirects today; the new names are the stable ones.
3. **`vim.hl`.** `vim.highlight.on_yank()` → `vim.hl.on_yank()` in `init.lua` (and its `:help` comment). Deprecated since 0.11.
4. **Health check.** In `lua/custom/health.lua`, raise the minimum from `'0.10-dev'` to `'0.12'` (nvim-treesitter `main` requires it) and add `tree-sitter`, `cc`, and `node` to the executables checked.
5. **Docs.** Update `TESTPLAN.md`'s treesitter sections (they describe `master`'s runtimepath behaviour) and add these migrations to `NEOVIM-0.12.md`, which currently covers only rustaceanvim.

**Done when:** `grep -rn "williamboman\|vim\.highlight\.\|0.10-dev" ~/projects/kickstart.nvim --include=*.lua` returns nothing, and the `gr` choice is applied per the user's answer.

## Step 7: Verify in isolation

Run the config under the target Neovim with throwaway XDG dirs so the real `~/.config/nvim` and `~/.local/share/nvim` stay untouched. Downloads go in their own empty directory.

```bash
T=$(mktemp -d); mkdir -p "$T"/xdg/{config,data,state,cache}
cp -r ~/projects/kickstart.nvim "$T/xdg/config/nvim" && rm -rf "$T/xdg/config/nvim/.git"
export XDG_CONFIG_HOME=$T/xdg/config XDG_DATA_HOME=$T/xdg/data XDG_STATE_HOME=$T/xdg/state XDG_CACHE_HOME=$T/xdg/cache
N=~/bin/nv   # the 0.12.6 install from `make neovim`
$N --headless "+Lazy! sync" +qa
# first start installs parsers and mason tools asynchronously: start once, wait, quit
$N --headless "+sleep 60" +qa
```

Then probe a `.lua` and a `.py` file headlessly (wait ~10s after open for LSP attach) and check every **done when** from steps 4–6: treesitter active on Python, `lua_ls` carries `callSnippet = 'Replace'`, no `stylua` client, `:messages` free of errors, `:checkhealth vim.deprecated` OK. Remove `$T` afterwards by its literal path.

**Done when:** every check passes in the isolated run.

## Step 8: Lock plugin versions (kickstart)

Plugin drift caused this migration; a lockfile turns future plugin updates into a deliberate, reversible `:Lazy update`.

- Remove `lazy-lock.json` from `kickstart.nvim/.gitignore`.
- Generate it from the verified run (`$T/xdg/config/nvim/lazy-lock.json`) or by running `:Lazy sync` against the real config after deploying, and copy it into the kickstart repo.

**Done when:** `git -C ~/projects/kickstart.nvim status` shows `lazy-lock.json` as a new tracked-candidate file and `.gitignore` no longer lists it.

## Out of scope

- **nvim-cmp** keeps working; upstream kickstart moved to blink.cmp, a preference rather than a fix.
- **telescope, neotest, mini, indent-blankline** use Neovim's built-in treesitter API and need only the parsers from step 4.
- **Neovim stays pinned** in `scripts/install_neovim.sh` (0.12.6): a Neovim bump is what can break the config, so it remains a deliberate edit, unlike sesh and tree-sitter.

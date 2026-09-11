# Claude Code Configuration Files: `~/.claude/settings.json` vs `~/.claude.json`

> Researched against official docs at https://code.claude.com/docs/en/settings and https://code.claude.com/docs/en/mcp  
> Date: 2026-09-11

---

## Summary

The user is correct: **MCP servers are configured in `~/.claude.json`, not `~/.claude/settings.json`.**

---

## `~/.claude/settings.json` — User settings

**Purpose:** Personal preferences that apply to every project on this machine.

**What it stores** ([source](https://code.claude.com/docs/en/settings#settings-files-and-who-they-affect)):
- `permissions` — allow/deny rules for tools and Bash commands
- `hooks` — scripts to run at session events
- `model` — default model
- `env` — environment variables injected into every session
- `statusLine` — custom status line
- `outputStyle` — output style selection

**Does NOT store MCP servers.** The official docs list the valid keys for settings.json and `mcpServers` is not among them.

**Created by:** `/config` menu (most options), or hand-edited. Claude Code creates it the first time you change a theme or similar option.

---

## `~/.claude.json` — App state and personal MCP config

**Purpose:** App state that doesn't belong in settings.json. Claude Code manages this file; you don't need to edit it directly (though you can via `claude mcp add`).

**What it stores** ([source](https://code.claude.com/docs/en/claude-directory)):
- OAuth/sign-in session
- **MCP server configurations** (user-scoped: all projects; local-scoped: one project)
- Per-project state: trust-dialog acceptance, last-session metrics
- UI toggles: `autoConnectIde`, `externalEditorContext`
- Theme and other `/config`-managed global config keys

**Example structure:**
```json
{
  "autoConnectIde": true,
  "mcpServers": {
    "my-tools": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  },
  "projects": {
    "/path/to/project": {
      "hasTrustDialogAccepted": true,
      "mcpServers": { ... }
    }
  }
}
```

The `mcpServers` key at the top level = **user scope** (all projects).  
The `mcpServers` key nested under `projects.<path>` = **local scope** (that project only, not committed).

---

## MCP server scopes and their files

| Scope | File | Who sees it | How to add |
|---|---|---|---|
| User (all projects, private) | `~/.claude.json` | You only | `claude mcp add --scope user` |
| Local (one project, private) | `~/.claude.json` under `projects.<path>` | You only | `claude mcp add` (default scope) |
| Project (team-shared) | `.mcp.json` at project root | Everyone who clones the repo | `claude mcp add --scope project` |

Source: https://code.claude.com/docs/en/mcp

---

## Implication for `settings.imprivata.json`

The named settings file `~/.claude/settings.imprivata.json` (loaded via `claude --settings` or `CLAUDE_CODE_SETTINGS_FILE`) has an `mcpServers` key in it. This is **not documented as a valid settings.json key**. It may work through undocumented behavior or be silently ignored.

The documented, reliable way to configure MCP servers is `~/.claude.json` (for personal/user scope) or `.mcp.json` (for project/team scope). If the MCP servers in `settings.imprivata.json` are working, they should be migrated to `~/.claude.json` under the appropriate scope to follow the official pattern.

To add the AWS MCP servers to user scope properly:
```bash
claude mcp add --scope user aws-docs uvx awslabs.aws-documentation-mcp-server@latest
```
This writes to `~/.claude.json` and persists across all sessions regardless of which settings profile is loaded.

---

## Settings precedence (highest wins)

1. Managed settings (org-deployed)
2. `--settings` CLI flag / `CLAUDE_CODE_SETTINGS_FILE` env var
3. `.claude/settings.local.json` (project-local, gitignored)
4. `.claude/settings.json` (project-shared, committed)
5. `~/.claude/settings.json` (user, every project)

Source: https://code.claude.com/docs/en/settings#settings-files-and-precedence

`~/.claude.json` is outside this precedence stack — it's app state, not a settings layer.

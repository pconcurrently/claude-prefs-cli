# claude-prefs

A CLI tool to manage global Claude Code memories and skills across all your projects.

**Problem:** Claude Code stores memories per-project. When you start a new project, your preferences (commit style, package manager, coding conventions) don't carry over. You have to re-teach Claude every time.

**Solution:** `claude-prefs` (alias: `ccp`) maintains a central store of global memories and a saved skills list. Initialize any project in one command with an interactive picker to choose what to include. It also [works automatically with Claude Code](#works-with-claude-code-automatically) - after install, Claude Code can query and manage your memories and skills by name without any manual steps.

## Prerequisites

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) must be installed:

```bash
npm install -g @anthropic-ai/claude-code
```

## Install

One-liner:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/pccly/claude-prefs-cli/main/install.sh)
```

This will:

1. Check that Claude Code is installed
2. Clone the repo to `~/.claude/claude-prefs-cli/`
3. Symlink `claude-prefs` and `ccp` alias to `~/.claude/bin/`
4. Add `~/.claude/bin` to your PATH
5. Add `Bash(claude-prefs *)` and `Bash(ccp *)` permissions to Claude Code settings
6. Offer to run setup (loads defaults + initializes current project)

## Quick start

All commands work with both `claude-prefs` and `ccp`.

### First time (no memories or skills yet)

```bash
# Pick default memories to add to your global store
ccp add

# Pick skills to install from the saved list
ccp skills add

# Start a project - picker for which memories and skills to include
cd ~/my-project
ccp init
```

Each command shows a picker so you choose exactly what to include. Claude Code will use them automatically.

### Already have memories across projects

```bash
# Import existing memories from all projects into the global store
ccp import all

# Pick which memories and skills to include in a project
cd ~/my-project
ccp init
```

## Commands

Run `ccp help` for the full list.

| Command | Description |
| --- | --- |
| `list [here]` | List global memories, or current project's |
| `status` | Show sync status across all projects |
| `add [name...]` | Pick default memories to add, or add by name |
| `remove [here] <name>` | Remove a memory from global or current project |
| `init [dir]` | Initialize a project with memories + skills (per-project) |
| `sync [all\|here]` | Sync global memories to projects |
| `import [here\|all]` | Import memories from project(s) to global |
| `skills list [here]` | List saved skills, or current project's |
| `skills install [name]` | Download all saved, or search and add by name |
| `skills add [name...] [-y]` | Add skills by name, or pick from saved list |
| `skills remove [name]` | Remove a skill from global list (picker) |
| `skills remove here [name]` | Unlink skills from current project (picker) |
| `defaults list` | Preview bundled default memories and skills |
| `defaults load` | Load bundled defaults into global store |
| `setup` | Load defaults into global store |
| `update` | Update claude-prefs to the latest version |

All interactive commands support `-y` / `--yes` to skip the picker and select everything.

## Works with Claude Code automatically

After install, `ccp` adds a reference to `~/.claude/CLAUDE.md` so Claude Code knows about it in every project. Claude Code can query your memories and skills, then add exactly what's needed - no picker required.

**Example - Claude Code checks what's available and adds specific items:**

```bash
ccp defaults list
ccp list
ccp add feedback_no_em_dash feedback_use_pnpm
ccp skills add conventional-commit api-design
ccp init -y
```

**Example - Claude Code sets up a new project:**

```bash
ccp skills list
ccp skills add typescript-advanced-types nodejs-backend-patterns
ccp init -y
```

All commands have non-interactive forms that work without a TTY, so Claude Code can call them directly.

**How it works:** Running `ccp setup` or the installer writes a reference block to `~/.claude/CLAUDE.md` with all available commands. This is loaded into every Claude Code conversation automatically, so Claude Code knows how to use `ccp` without being told.

## License

MIT

## macOS app prototype

This repo now also includes a native macOS prototype in [macos-app/README.md](/Users/po/code4po/claude-prefs-cli/macos-app/README.md).

It gives you a first desktop control center for:

- memories from bundled defaults and `~/.claude/global-memory`
- saved and installed skills from `~/.claude`, `~/.codex`, and `~/.agents`
- plugin bundles from shared plugin directories

Run it locally with:

```bash
cd macos-app
swift run
```

## Documentation

Full project notes live in the CCLY Obsidian vault at `~/Nextcloud/CCLY/Projects/claude-prefs-cli/`:

- **Hub:** `claude-prefs-cli.md` — purpose, install, command reference, architecture, status.
- **Guide:** `Guide.md` — workflow walkthroughs (importing, init, skills, sync, defaults, memory file format, updating, tips).

Architecture, sync semantics, and detailed workflow walkthroughs live in the vault — this README sticks to install + quick-start + command summary.

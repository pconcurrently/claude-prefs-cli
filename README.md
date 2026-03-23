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
bash <(curl -fsSL https://raw.githubusercontent.com/pconcurrently/claude-prefs-cli/main/install.sh)
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

## How it works

```text
~/.claude/
  claude-prefs-cli/       # Cloned repo (source of truth)
    defaults/
      memories/            # Bundled default memories
      skills.json          # Bundled default skills
    claude-prefs           # The CLI script
  global-memory/           # Your central memory store
    feedback_use_pnpm.md
    feedback_no_em_dash.md
    ...
  global-skills.json       # Saved skills list
  skills/                  # Global skills (shared by all projects)
  bin/
    claude-prefs -> ...    # Symlink to the CLI
    ccp -> ...             # Short alias
  projects/
    -Users-you-project-a/
      memory/              # Per-project memories (synced from global)
    -Users-you-project-b/
      memory/

~/my-project/
  .claude/
    skills/                # Per-project skills (symlinked from ~/.agents/skills/)
      conventional-commit -> ~/.agents/skills/conventional-commit
```

- **Global memories** live in `~/.claude/global-memory/`. These are your source of truth.
- **Defaults** are bundled in the repo under `defaults/`. Run `defaults load` or `setup` to pull them into global.
- `setup` loads bundled defaults into the global store. It offers to init the current project afterwards.
- `init` copies selected memories and symlinks selected skills into the project. It resolves the git root automatically, so you can run it from any subdirectory.
- `skills install <name>` searches skills.sh, downloads the skill, and adds it to the global list.
- `skills add` shows a picker to symlink saved skills into both `~/.claude/skills/` (global) and `<project>/.claude/skills/` (current project). Already-downloaded skills are symlinked instantly; only new skills are fetched.
- `sync all` pushes updates to every project that already has a memory directory.
- `import all` pulls non-project-specific memories from all projects into global (deduplicates automatically).
- `list here` shows the current project's memories with sync status (synced, modified locally, local only).
- **Skills** are managed via [skills.sh](https://skills.sh/) - `claude-prefs` saves your list and installs them with `npx skills add`.
- **Updates** are checked automatically once per day. Run `ccp update` to pull the latest version and load any new bundled defaults.
- **Claude Code integration** - install or setup writes a reference to `~/.claude/CLAUDE.md` so Claude Code knows about `ccp` in every project. All commands have non-interactive forms (`ccp add <name>`, `ccp skills add <name>`, `ccp init -y`) that Claude Code can call directly.

## License

MIT

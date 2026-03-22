# claude-prefs

A CLI tool to manage global Claude Code memories and skills across all your projects.

**Problem:** Claude Code stores memories per-project. When you start a new project, your preferences (commit style, package manager, coding conventions) don't carry over. You have to re-teach Claude every time.

**Solution:** `claude-prefs` maintains a central store of global memories and a saved skills list. Initialize any project in one command with an interactive picker to choose what to include.

## Install

One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/pconcurrently/claude-prefs-cli/main/install.sh | bash
```

This will:

1. Clone the repo to `~/.claude/claude-prefs-cli/`
2. Symlink `claude-prefs` to `~/.claude/bin/`
3. Add `~/.claude/bin` to your PATH
4. Add `Bash(claude-prefs *)` permission to Claude Code settings
5. Offer to load bundled default memories and skills

## Quick start

```bash
# Import your existing memories from all projects into the global store
claude-prefs import all

# Review what was imported
claude-prefs list

# Check current project's memories
claude-prefs list here

# Add a skill by name (searches skills.sh)
claude-prefs skills add conventional-commit

# Load defaults globally
claude-prefs setup

# Initialize a project (memories + skills)
cd ~/my-new-project
claude-prefs init
```

## Commands

Run `claude-prefs help` for the full list.

| Command | Description |
| --- | --- |
| `list [here]` | List global memories, or current project's |
| `status` | Show sync status across all projects |
| `add <file>` | Add a memory file to the global store |
| `remove <name or pattern>` | Remove a memory (supports fuzzy match) |
| `init [dir]` | Initialize a project with memories + skills (per-project) |
| `sync [all\|here]` | Sync global memories to projects |
| `import [here\|all]` | Import memories from project(s) to global |
| `skills list` | List saved skill repos |
| `skills add <name or repo>` | Add a skill (searches skills.sh by name) |
| `skills remove <name or pattern>` | Remove a skill (supports fuzzy match) |
| `skills install` | Install saved skills globally (interactive picker) |
| `defaults list` | Preview bundled default memories and skills |
| `defaults load` | Load bundled defaults into global store |
| `setup` | Load defaults into global store |
| `update` | Update claude-prefs to the latest version |

All interactive commands support `-y` / `--yes` to skip the picker and select everything.

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
- `init` copies selected memories into the Claude project directory and symlinks selected skills into `<project>/.claude/skills/`. It resolves the git root automatically, so you can run it from any subdirectory. Already-downloaded skills are symlinked instantly; only new skills are fetched via `npx skills add`.
- `skills install` installs skills globally to `~/.claude/skills/` (shared by all projects). Use `init` for per-project installation.
- `sync all` pushes updates to every project that already has a memory directory.
- `import all` pulls non-project-specific memories from all projects into global (deduplicates automatically).
- `list here` shows the current project's memories with sync status (synced, modified locally, local only).
- **Skills** are managed via [skills.sh](https://skills.sh/) - `claude-prefs` saves your list and installs them with `npx skills add`.
- **Updates** are checked automatically once per day. Run `claude-prefs update` to pull the latest version and load any new bundled defaults.

## License

MIT

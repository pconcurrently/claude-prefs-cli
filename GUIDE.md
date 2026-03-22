# Guide

A walkthrough of common workflows with `claude-prefs`.

## Building your global memory store

### Starting from scratch

If you already have Claude Code projects with memories, import them all at once:

```bash
claude-prefs import all
```

This scans every project under `~/.claude/projects/`, finds memory files, and copies them to the global store. It automatically:
- Skips `type: project` memories (project-specific, not portable)
- Skips duplicates (same filename already in global)

### Review and curate

After importing, check what you have:

```bash
claude-prefs list
```

Remove anything project-specific that slipped through:

```bash
claude-prefs remove feedback_sim_data_maker.md
```

### Adding memories manually

If you have a memory file you want to share globally:

```bash
# From a file path
claude-prefs add ~/code4po/my-project/.claude/memory/feedback_testing.md

# Or from the current project's memory dir (just the filename)
cd ~/code4po/my-project
claude-prefs add feedback_testing.md
```

## Setting up a new project

### Interactive setup (recommended)

```bash
cd ~/code4po/new-project
claude-prefs setup
```

This runs three steps in sequence:

**Step 1 - Defaults:** loads bundled default memories and skills into your global store (skips what's already there).

**Step 2 - Memories:** navigate with arrow keys, space to toggle, `a` for all/none, enter to confirm.

```
Select memories to install:
  [space] toggle  [a] all/none  [enter] confirm

  [x] [feedback]   No Co-Authored-By watermark in commits
  [x] [feedback]   Avoid magic numbers, use named constants
  [ ] [feedback]   No em dashes in output          <-- deselected
  [x] [feedback]   Always use pnpm
```

**Step 3 - Skills:** same picker for your saved skills list.

### Non-interactive setup

Skip the pickers and install everything:

```bash
claude-prefs setup -y
```

### Memories only (init)

```bash
claude-prefs init
```

`init` resolves the git root automatically, so running it from `~/code4po/my-project/src/` will initialize `my-project`. It also offers to install saved skills after syncing memories.

### Skills only

```bash
claude-prefs skills install
```

## Managing skills

### Save a skill repo

```bash
claude-prefs skills add anthropics/claude-code-skills
```

You'll be asked if you want to install it immediately. The repo is saved to your global list either way.

Pass extra flags for the `skills` CLI:

```bash
claude-prefs skills add vercel-labs/agent-skills --all
```

### View saved skills

```bash
claude-prefs skills list
```

### Install all saved skills

```bash
claude-prefs skills install
```

Shows an interactive picker. Use `-y` to install all without prompting.

### Remove a skill

```bash
claude-prefs skills remove vercel-labs/agent-skills
```

This removes it from your saved list only. It does not uninstall from existing projects.

## Viewing project memories

To see what memories are installed in the current project:

```bash
claude-prefs list here
```

Each memory shows its sync status:

- **(synced)** - matches the global version
- **(modified locally)** - differs from the global version
- **(local only)** - exists only in this project, not in global

To see your global memories:

```bash
claude-prefs list
```

## Using defaults

The repo ships with bundled default memories and skills in `defaults/`.

Preview what's included:

```bash
claude-prefs defaults list
```

Load them into your global store:

```bash
claude-prefs defaults load
```

This is also done automatically when you run `claude-prefs setup`. Defaults never overwrite existing entries - they only add what's missing.

## Keeping projects in sync

### Push updates to all projects

After updating a global memory, sync it to all projects that have memory directories:

```bash
claude-prefs sync all
```

Only changed or missing files are copied. Projects without a memory directory are skipped.

### Sync just the current project

```bash
claude-prefs sync here
```

### Check sync status

```bash
claude-prefs status
```

Shows each project and how many memories are synced, outdated, or missing:

```
Project Sync Status

  Global memories: 5

  -Users-po-project-a - 5 synced
  -Users-po-project-b - 3 synced, 2 missing
  -Users-po-project-c - no memory
```

## Memory file format

Memory files use YAML frontmatter:

```markdown
---
name: Prefer pnpm
description: Always use pnpm over npm/yarn
type: feedback
---

Use pnpm as the default package manager.

**Why:** User preference.

**How to apply:** When installing packages or running scripts, default to pnpm.
```

Types: `feedback`, `user`, `project`, `reference`. See the [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code) for details on memory types.

## Updating

`claude-prefs` checks for updates once per day. When an update is available, you'll see:

```text
Update available! Run claude-prefs update to update.
```

Run the update:

```bash
claude-prefs update
```

This pulls the latest changes and automatically loads any new bundled defaults (memories and skills).

## Tips

- **Import regularly.** Run `claude-prefs import all` periodically to pick up new memories from active projects.
- **Curate aggressively.** Not every memory belongs in global. Project-specific patterns, architecture decisions, and domain knowledge should stay local.
- **Use `sync all` after edits.** If you update a global memory file directly, run sync to push the change everywhere.
- **Let Claude use it.** Add `Bash(claude-prefs *)` to your permissions so Claude can run `claude-prefs setup` when you start a new project.
- **Works from subdirectories.** `init` and `setup` resolve the git root, so you don't need to be at the project root.

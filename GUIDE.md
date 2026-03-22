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

Remove anything project-specific that slipped through. Supports fuzzy matching:

```bash
claude-prefs remove sim_data       # lists all matching memories
claude-prefs remove feedback_sim_data_maker.md  # exact match
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

## Global setup

Load bundled defaults (memories and skills) into your global store:

```bash
claude-prefs setup
```

This adds any new defaults that aren't already in your global store, then asks if you want to initialize the current project.

## Setting up a new project

### Interactive init (recommended)

```bash
cd ~/code4po/new-project
claude-prefs init
```

This runs two steps:

**Step 1 - Memories:** navigate with arrow keys, space to toggle, `a` for all/none, enter to confirm.

```text
Select memories to install:
  [space] toggle  [a] all/none  [enter] confirm

  [x] [feedback]   No Co-Authored-By watermark in commits
  [x] [feedback]   Avoid magic numbers, use named constants
  [ ] [feedback]   No em dashes in output          <-- deselected
  [x] [feedback]   Always use pnpm
```

**Step 2 - Skills:** same picker for your saved skills list. Already-downloaded skills are symlinked instantly; only new skills are fetched via `npx skills add`.

`init` resolves the git root automatically, so running it from `~/code4po/my-project/src/` will initialize `my-project`.

### Non-interactive init

Skip the pickers and install everything:

```bash
claude-prefs init -y
```

### Skills only

```bash
claude-prefs skills install
```

## Managing skills

### Add a skill by name

```bash
claude-prefs skills add conventional-commit
```

This searches [skills.sh](https://skills.sh/) and picks the top result. You'll be asked if you want to install it immediately.

You can also use the full `owner/repo` format with `--skill`:

```bash
claude-prefs skills add vercel-labs/agent-skills --skill web-design-guidelines
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

Supports exact or fuzzy matching:

```bash
claude-prefs skills remove conventional-commit
claude-prefs skills remove dotnet    # lists all matching skills
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

This is also done automatically when you run `claude-prefs setup` or `claude-prefs update`. Defaults never overwrite existing entries - they only add what's missing.

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

```text
Project Sync Status

  Global memories: 5

  project-a - 5 synced
  project-b - 3 synced, 2 missing
  project-c - no memory
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
- **Works from subdirectories.** `init` resolves the git root, so you don't need to be at the project root.

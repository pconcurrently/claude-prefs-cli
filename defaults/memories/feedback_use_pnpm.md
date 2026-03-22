---
name: Prefer pnpm as package manager
description: Always use pnpm over npm/yarn whenever possible for installs, scripts, and project setup
type: feedback
---

Use pnpm as the default package manager whenever possible. Prefer `pnpm install`, `pnpm add`, `pnpm run` over npm/yarn equivalents.

**Why:** User preference for pnpm across all projects.

**How to apply:** When installing packages, running scripts, initializing projects, or suggesting commands, always default to pnpm. Only fall back to npm/yarn if pnpm is unavailable or the project explicitly requires another manager (e.g., has a package-lock.json with no pnpm-lock.yaml).

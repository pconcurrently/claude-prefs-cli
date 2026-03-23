#!/usr/bin/env bash
# Install claude-prefs CLI
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
DIM='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="$HOME/.claude/bin"
SCRIPT_NAME="claude-prefs"
REPO="pconcurrently/claude-prefs-cli"
CLONE_DIR="$HOME/.claude/claude-prefs-cli"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo -e "${BOLD}Installing claude-prefs${NC}"
echo ""

# Check if Claude Code is installed
if ! command -v claude &>/dev/null && [[ ! -d "$HOME/.claude" ]]; then
  echo -e "  Claude Code is required but not installed."
  echo ""
  echo -e "  Install it with:  ${CYAN}npm install -g @anthropic-ai/claude-code${NC}"
  echo -e "  ${DIM}More info: https://docs.anthropic.com/en/docs/claude-code${NC}"
  exit 1
fi

# 1. Clone or update the repo (so defaults/ is available)
mkdir -p "$INSTALL_DIR"
if [[ -d "$CLONE_DIR/.git" ]]; then
  echo -e "  ${CYAN}Updating repo...${NC}"
  git -C "$CLONE_DIR" pull --quiet 2>/dev/null || true
else
  echo -e "  ${CYAN}Cloning repo...${NC}"
  git clone --quiet "https://github.com/$REPO.git" "$CLONE_DIR" 2>/dev/null
fi

# 2. Symlink the script
ln -sf "$CLONE_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
ln -sf "$CLONE_DIR/$SCRIPT_NAME" "$INSTALL_DIR/ccp"
chmod +x "$CLONE_DIR/$SCRIPT_NAME"
echo -e "  ${GREEN}Installed to $INSTALL_DIR/$SCRIPT_NAME${NC}"
echo -e "  ${GREEN}Alias: ccp${NC}"

# 3. Add to PATH if needed
SHELL_RC=""
if ! echo "$PATH" | tr ':' '\n' | grep -q "$INSTALL_DIR"; then
  if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
  elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_RC="$HOME/.bash_profile"
  fi

  if [[ -n "$SHELL_RC" ]]; then
    if ! grep -q '.claude/bin' "$SHELL_RC" 2>/dev/null; then
      echo '' >> "$SHELL_RC"
      echo '# claude-prefs CLI' >> "$SHELL_RC"
      echo 'export PATH="$HOME/.claude/bin:$PATH"' >> "$SHELL_RC"
      echo -e "  ${GREEN}Added ~/.claude/bin to PATH in $SHELL_RC${NC}"
    else
      echo -e "  ${DIM}PATH already configured in $SHELL_RC${NC}"
    fi
  fi
fi

# 4. Add Claude Code permission if settings.json exists
if [[ -f "$SETTINGS_FILE" ]]; then
  if ! grep -q 'claude-prefs' "$SETTINGS_FILE" 2>/dev/null; then
    python3 -c "
import json
with open('$SETTINGS_FILE', 'r') as f:
    settings = json.load(f)
perms = settings.setdefault('permissions', {})
allow = perms.setdefault('allow', [])
if 'Bash(claude-prefs *)' not in allow:
    allow.append('Bash(claude-prefs *)')
if 'Bash(ccp *)' not in allow:
    allow.append('Bash(ccp *)')
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
" 2>/dev/null && echo -e "  ${GREEN}Added permission to Claude Code settings${NC}" \
             || echo -e "  ${DIM}Could not update settings.json (update manually)${NC}"
  else
    echo -e "  ${DIM}Claude Code permission already set${NC}"
  fi
else
  echo -e "  ${DIM}No ~/.claude/settings.json found - add permission manually if needed${NC}"
fi

# 5. Add ccp reference to global CLAUDE.md
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CCP_MARKER="<!-- ccp-reference -->"

if [[ -f "$CLAUDE_MD" ]] && grep -q "$CCP_MARKER" "$CLAUDE_MD" 2>/dev/null; then
  echo -e "  ${DIM}CLAUDE.md already has ccp reference${NC}"
else
  CCP_BLOCK="
$CCP_MARKER
## claude-prefs (ccp)

\`ccp\` is a CLI tool for managing global Claude Code memories and skills. Run \`ccp help\` for all commands.

### Query commands

- \`ccp list\` - list all global memories
- \`ccp list here\` - list current project's memories
- \`ccp skills list\` - list all saved skills
- \`ccp skills list here\` - list current project's skills
- \`ccp defaults list\` - preview bundled default memories and skills

### Non-interactive commands (use these to add specific items by name)

- \`ccp add <name> [name2...]\` - add default memories by name (e.g. \`ccp add feedback_no_em_dash feedback_use_pnpm\`)
- \`ccp skills add <name> [name2...]\` - add specific skills by name (e.g. \`ccp skills add conventional-commit api-design\`)
- \`ccp skills install <name>\` - search and download a skill from skills.sh
- \`ccp init -y\` - initialize current project with all global memories and skills
- \`ccp import all\` - import memories from all projects into global store

### Interactive commands (picker UI, for human use)

- \`ccp add\` - pick default memories to add
- \`ccp skills add\` - pick skills to install
- \`ccp init\` - pick memories and skills for current project
<!-- /ccp-reference -->"

  if [[ -f "$CLAUDE_MD" ]]; then
    echo "$CCP_BLOCK" >> "$CLAUDE_MD"
  else
    echo "$CCP_BLOCK" > "$CLAUDE_MD"
  fi
  echo -e "  ${GREEN}Added ccp reference to ~/.claude/CLAUDE.md${NC}"
fi

# 6. Offer to run setup
echo ""
read -rp "Run setup now? (loads defaults + inits current project) [Y/n] " answer </dev/tty
answer="${answer:-y}"
if [[ "$answer" =~ ^[Yy] ]]; then
  echo ""
  export PATH="$INSTALL_DIR:$PATH"
  claude-prefs setup
fi

echo ""
echo -e "${GREEN}Done!${NC} Run ${CYAN}ccp help${NC} to get started."
if [[ -n "$SHELL_RC" ]]; then
  echo -e "${DIM}If the command is not found, run: source $SHELL_RC${NC}"
fi

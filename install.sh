#!/usr/bin/env bash
# Install claude-prefs CLI
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
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
chmod +x "$CLONE_DIR/$SCRIPT_NAME"
echo -e "  ${GREEN}Installed to $INSTALL_DIR/$SCRIPT_NAME${NC}"

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

# 5. Offer to load defaults
echo ""
read -rp "Load default memories and skills? [Y/n] " answer
answer="${answer:-y}"
if [[ "$answer" =~ ^[Yy] ]]; then
  echo ""
  export PATH="$INSTALL_DIR:$PATH"
  claude-prefs defaults load
fi

echo ""
echo -e "${GREEN}Done!${NC} Run ${CYAN}claude-prefs help${NC} to get started."
if [[ -n "$SHELL_RC" ]]; then
  echo -e "${DIM}If the command is not found, run: source $SHELL_RC${NC}"
fi

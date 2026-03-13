#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# install.sh — Install the setup-vibe-kanban Claude Code skill
#
# Usage:
#   ./install.sh              Install the skill
#   ./install.sh --uninstall  Remove the skill
#
# One-liner (curl):
#   curl -fsSL https://raw.githubusercontent.com/daniel-viact/viact-skills/main/install.sh | bash
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SKILL_NAME="setup-vibe-kanban"
SKILLS_DIR="${CLAUDE_COMMANDS_DIR:-$HOME/.claude/commands}"
SKILL_FILE="$SKILLS_DIR/$SKILL_NAME.md"
GITHUB_RAW="https://raw.githubusercontent.com/daniel-viact/viact-skills/main/SKILL.md"

# ── Colors ────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
else
  GREEN=''; YELLOW=''; RED=''; BOLD=''; NC=''
fi

ok()   { echo -e "${GREEN}  ✓${NC}  $1"; }
warn() { echo -e "${YELLOW}  !${NC}  $1"; }
err()  { echo -e "${RED}  ✗${NC}  $1" >&2; }
hr()   { echo "  ────────────────────────────────────────────"; }

# ── Uninstall ─────────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--uninstall" ]]; then
  echo ""
  echo -e "${BOLD}  Uninstalling $SKILL_NAME${NC}"
  hr
  if [[ -f "$SKILL_FILE" ]]; then
    rm "$SKILL_FILE"
    ok "Removed $SKILL_FILE"
  else
    warn "Skill not found at $SKILL_FILE — nothing to remove."
  fi
  echo ""
  exit 0
fi

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}  Claude Code Skill Installer${NC}"
echo -e "  $SKILL_NAME"
hr
echo ""

# ── Create skills directory ───────────────────────────────────────────────────
if [[ ! -d "$SKILLS_DIR" ]]; then
  mkdir -p "$SKILLS_DIR"
  ok "Created commands directory: $SKILLS_DIR"
else
  ok "Commands directory: $SKILLS_DIR"
fi

# ── Resolve skill source: local file or download from GitHub ──────────────────
# When piped via `curl | bash`, BASH_SOURCE[0] is empty or "-"
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "-" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
fi
LOCAL_SKILL="${SCRIPT_DIR:+$SCRIPT_DIR/SKILL.md}"

if [[ -n "$LOCAL_SKILL" && -f "$LOCAL_SKILL" ]]; then
  cp "$LOCAL_SKILL" "$SKILL_FILE"
  ok "Installed from local file: $LOCAL_SKILL"
else
  warn "No local SKILL.md found — downloading from GitHub..."
  if command -v curl &>/dev/null; then
    curl -fsSL "$GITHUB_RAW" -o "$SKILL_FILE"
  elif command -v wget &>/dev/null; then
    wget -qO "$SKILL_FILE" "$GITHUB_RAW"
  else
    err "Neither curl nor wget is available. Install one and try again."
    exit 1
  fi
  ok "Downloaded latest skill from GitHub"
fi

# ── Verify ────────────────────────────────────────────────────────────────────
if [[ ! -s "$SKILL_FILE" ]]; then
  err "Skill file is empty or missing after install — something went wrong."
  exit 1
fi

ok "Skill file ready: $SKILL_FILE"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
hr
echo ""
echo -e "${GREEN}${BOLD}  ✅  Installation complete!${NC}"
echo ""
echo "  Open Claude Code and trigger the command with:"
echo ""
echo "    → \"setup vibe kanban\""
echo "    → \"install vibe kanban docker\""
echo "    → \"setup kanban shared workstation\""
echo ""
echo "  Or use the slash command directly:"
echo ""
echo "    /setup-vibe-kanban"
echo ""
echo "  To uninstall:"
echo ""
echo "    ./install.sh --uninstall"
echo "    # or"
echo "    rm \"$SKILL_FILE\""
echo ""

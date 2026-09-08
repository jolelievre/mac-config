#!/bin/sh
# Wire the local PrestaShop environment into Claude Code (OPTIONAL step)
# Usage: sh install/17-prestashop-claude.sh
#
# Only for machines used for PrestaShop development. Needs install/06-prestashop-tools.sh
# (clones ~/dev/ps-install-tools and ~/dev/prestashop-claude-skills) and jq.
#
# What it does:
#   1. Imports ~/dev/ps-install-tools/claude/CLAUDE.md from ~/.claude/CLAUDE.md
#      (always-on knowledge of the local instances and the ps-* tools)
#   2. Adds a SessionStart hook running ps-install-tools/claude/session-start.sh
#      (prints ps-infos when a session opens inside ~/www/prestashop-<suffix>)
#   3. Allows the read-only ps-infos command without permission prompt
#   4. Symlinks the developer skills of ~/dev/prestashop-claude-skills (PrestaShop/skills)
#      into ~/.claude/skills/ (e.g. prestashop-pr-qa)
#
# Each section is idempotent: re-run it any time, it only adds what is missing.

set -e

CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
TOOLS_DIR="$HOME/dev/ps-install-tools"
SKILLS_REPO="$HOME/dev/prestashop-claude-skills"

if [ ! -d "$TOOLS_DIR" ]; then
  echo "  [skip]    $TOOLS_DIR not found: run install/06-prestashop-tools.sh first"
  exit 0
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "  [error]   jq is required (brew install jq)"
  exit 1
fi

mkdir -p "$CLAUDE_DIR"
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# --- CLAUDE.md import -------------------------------------------------------

echo "=== CLAUDE.md import ==="

IMPORT_LINE='@~/dev/ps-install-tools/claude/CLAUDE.md'

if [ -f "$CLAUDE_MD" ] && grep -qxF "$IMPORT_LINE" "$CLAUDE_MD"; then
  echo "  [ok]      $IMPORT_LINE already imported"
else
  if [ -s "$CLAUDE_MD" ]; then
    echo "" >> "$CLAUDE_MD"
  fi
  {
    echo "# PrestaShop local environment (ps-install-tools)"
    echo "$IMPORT_LINE"
  } >> "$CLAUDE_MD"
  echo "  [added]   $IMPORT_LINE to $CLAUDE_MD"
fi

# --- SessionStart hook -------------------------------------------------------

echo ""
echo "=== SessionStart hook ==="

HOOK_SCRIPT="ps-install-tools/claude/session-start.sh"
HOOK_CMD="\"\$HOME/dev/$HOOK_SCRIPT\""

if jq -e --arg s "$HOOK_SCRIPT" '[.hooks.SessionStart[]?.hooks[]?.command // "" | select(contains($s))] | length > 0' "$SETTINGS" >/dev/null 2>&1; then
  echo "  [ok]      $HOOK_SCRIPT hook already configured"
else
  TMPFILE=$(mktemp)
  jq --arg cmd "$HOOK_CMD" '.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"hooks": [{"type": "command", "command": $cmd, "timeout": 20}]}])' "$SETTINGS" > "$TMPFILE"
  mv "$TMPFILE" "$SETTINGS"
  echo "  [added]   SessionStart hook -> $HOOK_CMD"
fi

# --- Permissions ------------------------------------------------------------

echo ""
echo "=== Permissions (read-only ps-infos) ==="

for RULE in "Bash(ps-infos:*)" "Bash($TOOLS_DIR/ps-infos.sh:*)"; do
  if jq -e --arg r "$RULE" '(.permissions.allow // []) | index($r) != null' "$SETTINGS" >/dev/null 2>&1; then
    echo "  [ok]      $RULE"
  else
    TMPFILE=$(mktemp)
    jq --arg r "$RULE" '.permissions.allow = ((.permissions.allow // []) + [$r])' "$SETTINGS" > "$TMPFILE"
    mv "$TMPFILE" "$SETTINGS"
    echo "  [added]   $RULE"
  fi
done

# --- PrestaShop developer skills ---------------------------------------------

echo ""
echo "=== PrestaShop developer skills ==="

if [ ! -d "$SKILLS_REPO" ]; then
  echo "  [skip]    $SKILLS_REPO not found: run install/06-prestashop-tools.sh to clone PrestaShop/skills"
else
  mkdir -p "$CLAUDE_DIR/skills"
  FOUND=0

  for SKILL_DIR in "$SKILLS_REPO"/*/dev/*/; do
    [ -f "$SKILL_DIR/SKILL.md" ] || continue
    FOUND=1
    SKILL_DIR="${SKILL_DIR%/}"
    NAME="$(basename "$SKILL_DIR")"
    TARGET="$CLAUDE_DIR/skills/$NAME"

    if [ -L "$TARGET" ]; then
      CURRENT=$(readlink "$TARGET")
      if [ "$CURRENT" = "$SKILL_DIR" ]; then
        echo "  [ok]      $NAME (symlink already up to date)"
      else
        ln -sfn "$SKILL_DIR" "$TARGET"
        echo "  [updated] $NAME -> $SKILL_DIR (was $CURRENT)"
      fi
    elif [ -d "$TARGET" ]; then
      echo "  [skip]    $NAME ($TARGET exists and is not a symlink)"
      printf "            Replace it with a symlink? [y/N] "
      read -r REPLY || REPLY=""
      if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
        rm -rf "$TARGET"
        ln -s "$SKILL_DIR" "$TARGET"
        echo "  [replaced] $NAME -> $SKILL_DIR"
      else
        echo "            Skipped. Remove $TARGET manually and re-run."
      fi
    else
      ln -s "$SKILL_DIR" "$TARGET"
      echo "  [new]     $NAME -> $SKILL_DIR"
    fi
  done

  if [ $FOUND -eq 0 ]; then
    echo "  [skip]    no */dev/*/SKILL.md found in $SKILLS_REPO"
  fi
fi

echo ""
echo "Done! Restart Claude Code to pick up changes."

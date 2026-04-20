#!/bin/sh
# Install / update Claude Code configuration
# Usage: sh install/15-claude-config.sh
#
# What it does:
#   1. Symlinks statusline.sh into ~/.claude/
#   2. Adds the statusLine config to ~/.claude/settings.json
#   3. Symlinks each skill directory from claude/skills/ into ~/.claude/skills/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

mkdir -p "$CLAUDE_DIR"

# --- Status line -----------------------------------------------------------

echo "=== Status line ==="

SOURCE="$REPO_DIR/claude/statusline.sh"
TARGET="$CLAUDE_DIR/statusline.sh"

if [ ! -f "$SOURCE" ]; then
  echo "  [skip] $SOURCE not found"
else
  chmod +x "$SOURCE"

  if [ -L "$TARGET" ]; then
    CURRENT=$(readlink "$TARGET")
    if [ "$CURRENT" = "$SOURCE" ]; then
      echo "  [ok]      statusline.sh (symlink already up to date)"
    else
      ln -sf "$SOURCE" "$TARGET"
      echo "  [updated] statusline.sh -> $SOURCE"
    fi
  elif [ -f "$TARGET" ]; then
    echo "  [skip]    statusline.sh ($TARGET exists and is not a symlink)"
    printf "            Replace it with a symlink? [y/N] "
    read -r REPLY
    if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
      rm "$TARGET"
      ln -s "$SOURCE" "$TARGET"
      echo "  [replaced] statusline.sh -> $SOURCE"
    else
      echo "            Skipped. Remove $TARGET manually and re-run."
    fi
  else
    ln -s "$SOURCE" "$TARGET"
    echo "  [new]     statusline.sh -> $SOURCE"
  fi

  # Update settings.json
  if [ ! -f "$SETTINGS" ]; then
    echo '{}' > "$SETTINGS"
  fi

  if jq -e '.statusLine' "$SETTINGS" >/dev/null 2>&1; then
    echo "  [ok]      statusLine already configured in settings.json"
  else
    TMPFILE=$(mktemp)
    jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS" > "$TMPFILE"
    mv "$TMPFILE" "$SETTINGS"
    echo "  [added]   statusLine config to settings.json"
  fi
fi

# --- Skills ----------------------------------------------------------------

echo ""
echo "=== Skills ==="

SKILLS_SOURCE="$REPO_DIR/claude/skills"
SKILLS_TARGET="$CLAUDE_DIR/skills"

if [ ! -d "$SKILLS_SOURCE" ]; then
  echo "  [skip] $SKILLS_SOURCE not found"
else
  mkdir -p "$SKILLS_TARGET"

  INSTALLED=0
  SKIPPED=0

  for SKILL_DIR in "$SKILLS_SOURCE"/*/; do
    [ -d "$SKILL_DIR" ] || continue

    SKILL_NAME="$(basename "$SKILL_DIR")"
    TARGET="$SKILLS_TARGET/$SKILL_NAME"

    if [ -L "$TARGET" ]; then
      CURRENT=$(readlink "$TARGET")
      if [ "$CURRENT" = "$SKILL_DIR" ] || [ "$CURRENT" = "${SKILL_DIR%/}" ]; then
        echo "  [ok]      $SKILL_NAME (symlink already up to date)"
        INSTALLED=$((INSTALLED + 1))
      else
        ln -sfn "$SKILL_DIR" "$TARGET"
        echo "  [updated] $SKILL_NAME -> $SKILL_DIR"
        INSTALLED=$((INSTALLED + 1))
      fi
    elif [ -d "$TARGET" ]; then
      echo "  [skip]    $SKILL_NAME ($TARGET exists and is not a symlink)"
      SKIPPED=$((SKIPPED + 1))
    else
      ln -s "$SKILL_DIR" "$TARGET"
      echo "  [new]     $SKILL_NAME -> $SKILL_DIR"
      INSTALLED=$((INSTALLED + 1))
    fi
  done

  echo "  $INSTALLED skill(s) installed, $SKIPPED skipped."
fi

echo ""
echo "Done! Restart Claude Code to pick up changes."

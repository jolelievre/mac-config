#!/bin/sh
# Install / update Claude Code custom status line
# Usage: sh claude/install-statusline.sh
#
# What it does:
#   1. Symlinks statusline.sh into ~/.claude/
#   2. Adds the statusLine config to ~/.claude/settings.json

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/statusline.sh"
TARGET="$HOME/.claude/statusline.sh"
SETTINGS="$HOME/.claude/settings.json"

# Ensure source exists
if [ ! -f "$SOURCE" ]; then
  echo "Error: $SOURCE not found"
  exit 1
fi

# Ensure ~/.claude/ exists
mkdir -p "$HOME/.claude"

# Make source executable
chmod +x "$SOURCE"

# Create or update symlink
if [ -L "$TARGET" ]; then
  CURRENT=$(readlink "$TARGET")
  if [ "$CURRENT" = "$SOURCE" ]; then
    echo "Symlink already up to date: $TARGET -> $SOURCE"
  else
    ln -sf "$SOURCE" "$TARGET"
    echo "Updated symlink: $TARGET -> $SOURCE"
  fi
elif [ -f "$TARGET" ]; then
  echo "Warning: $TARGET exists and is not a symlink."
  printf "Replace it with a symlink? [y/N] "
  read -r REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    rm "$TARGET"
    ln -s "$SOURCE" "$TARGET"
    echo "Replaced with symlink: $TARGET -> $SOURCE"
  else
    echo "Skipped. Please remove $TARGET manually and re-run."
    exit 1
  fi
else
  ln -s "$SOURCE" "$TARGET"
  echo "Created symlink: $TARGET -> $SOURCE"
fi

# Update settings.json
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Check if statusLine is already configured
if jq -e '.statusLine' "$SETTINGS" >/dev/null 2>&1; then
  echo "statusLine already configured in $SETTINGS"
else
  TMPFILE=$(mktemp)
  jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS" > "$TMPFILE"
  mv "$TMPFILE" "$SETTINGS"
  echo "Added statusLine config to $SETTINGS"
fi

echo ""
echo "Done! Restart Claude Code to see your custom status line."

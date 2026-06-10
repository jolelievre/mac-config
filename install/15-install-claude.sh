#!/bin/sh
# Install / update Claude Code via the official native installer
# Usage: sh install/15-install-claude.sh
#
# What it does:
#   1. Uninstalls any existing Homebrew claude-code cask (sunset path)
#   2. Runs the official native installer from https://claude.ai/install.sh
#      (latest channel, auto-updates in the background)
#   3. Verifies the install and warns about leftover binaries
#
# User config in ~/.claude/ (settings, memory, projects, skills, statusline)
# is never touched by this script.

set -e

# --- Detect existing Homebrew install --------------------------------------

echo "=== Detect existing Homebrew install ==="

REMOVED_ANY=0
if command -v brew >/dev/null 2>&1; then
  for CASK in claude-code claude-code@latest; do
    if brew list --cask --versions "$CASK" >/dev/null 2>&1; then
      echo "  [found]   $CASK installed via Homebrew, uninstalling..."
      brew uninstall --cask "$CASK"
      echo "  [removed] $CASK"
      REMOVED_ANY=1
    fi
  done
  if [ "$REMOVED_ANY" -eq 0 ]; then
    echo "  [ok]      no Homebrew claude-code cask present"
  fi
else
  echo "  [ok]      Homebrew not installed, skipping cask check"
fi

# --- Install Claude Code (native) ------------------------------------------

echo ""
echo "=== Install Claude Code (native) ==="

# Make sure ~/.local/bin is on PATH for the verification step below;
# the installer also adds it to the shell rc, but the current shell won't
# see that until it's restarted.
export PATH="$HOME/.local/bin:$PATH"

if [ -x "$HOME/.local/bin/claude" ] && "$HOME/.local/bin/claude" --version >/dev/null 2>&1; then
  VERSION=$("$HOME/.local/bin/claude" --version 2>/dev/null | head -n1)
  echo "  [ok]      already installed ($VERSION)"
else
  echo "  [new]     running https://claude.ai/install.sh ..."
  curl -fsSL https://claude.ai/install.sh | bash
  echo "  [done]    native installer finished"
fi

# --- Verify ----------------------------------------------------------------

echo ""
echo "=== Verify ==="

if [ ! -x "$HOME/.local/bin/claude" ]; then
  echo "  [warn]    ~/.local/bin/claude not found after install"
else
  VERSION=$("$HOME/.local/bin/claude" --version 2>/dev/null | head -n1)
  echo "  [ok]      ~/.local/bin/claude ($VERSION)"
fi

RESOLVED=$(command -v claude 2>/dev/null || true)
if [ -z "$RESOLVED" ]; then
  echo "  [warn]    'claude' not on PATH yet (open a new terminal to pick up ~/.local/bin)"
elif [ "${RESOLVED#/opt/homebrew/}" != "$RESOLVED" ]; then
  echo "  [warn]    'claude' still resolves to $RESOLVED (Homebrew leftover?)"
else
  echo "  [ok]      'claude' resolves to $RESOLVED"
fi

echo ""
echo "Done! Open a new terminal so ~/.local/bin is on PATH, then run:"
echo "  claude doctor"
echo "Next: sh install/16-claude-config.sh (statusline + skills)"

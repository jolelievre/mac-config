#!/bin/sh
# Install / update Claude Code configuration
# Usage: sh install/16-claude-config.sh
#
# What it does:
#   1. Symlinks statusline.sh into ~/.claude/
#   2. Adds the statusLine config to ~/.claude/settings.json
#   3. Symlinks each skill directory from claude/skills/ into ~/.claude/skills/
#   4. Installs/updates the caveman plugin + seeds ~/.config/caveman/config.json
#   5. Installs/updates rtk + wires its Claude Code hook (rtk init)
#   6. Symlinks the shared claude/rtk-config.toml into rtk's config location
#
# Each section is independent and idempotent: run it on any device and it
# installs whatever is missing, updates what's present, and leaves customized
# config files alone.

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

# --- caveman plugin --------------------------------------------------------

echo ""
echo "=== caveman plugin ==="

# `claude` is installed by 15 into ~/.local/bin; make sure it's reachable here
# even if the shell rc hasn't been re-sourced yet.
export PATH="$HOME/.local/bin:$PATH"

if ! command -v claude >/dev/null 2>&1; then
  echo "  [skip]    'claude' not on PATH (run install/15-install-claude.sh, then reopen terminal)"
elif ! command -v node >/dev/null 2>&1; then
  echo "  [skip]    node not found (caveman installer needs Node >= 18; run install/08-node.sh)"
else
  if claude plugin list 2>/dev/null | grep -q "caveman@caveman"; then
    claude plugin update caveman@caveman >/dev/null 2>&1 || true
    echo "  [ok]      caveman@caveman installed (checked for update)"
  else
    echo "  [new]     installing caveman via official installer..."
    curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
    echo "  [done]    caveman installed"
  fi
fi

# --- caveman config --------------------------------------------------------

echo ""
echo "=== caveman config ==="

CAVEMAN_CFG_DIR="$HOME/.config/caveman"
CAVEMAN_CFG="$CAVEMAN_CFG_DIR/config.json"
mkdir -p "$CAVEMAN_CFG_DIR"

if [ -f "$CAVEMAN_CFG" ]; then
  CURRENT_MODE=$(jq -r '.defaultMode // "unknown"' "$CAVEMAN_CFG" 2>/dev/null || echo "unknown")
  echo "  [ok]      config.json exists (defaultMode: $CURRENT_MODE) — left unchanged"
else
  printf '{ "defaultMode": "lite" }\n' > "$CAVEMAN_CFG"
  echo "  [new]     config.json -> defaultMode: lite"
fi

# --- rtk (token proxy) -----------------------------------------------------

echo ""
echo "=== rtk (token proxy) ==="

if ! command -v brew >/dev/null 2>&1; then
  echo "  [skip]    Homebrew not installed, skipping rtk"
else
  if command -v rtk >/dev/null 2>&1; then
    brew upgrade rtk >/dev/null 2>&1 || true
    echo "  [ok]      rtk present ($(rtk --version 2>/dev/null | head -n1))"
  else
    echo "  [new]     installing rtk via Homebrew..."
    brew install rtk
    echo "  [done]    rtk ($(rtk --version 2>/dev/null | head -n1))"
  fi

  # Wire up the Claude Code hook (hook + RTK.md + @RTK.md + settings.json).
  # Idempotent and safe to re-run; this is rtk's canonical setup command.
  if command -v rtk >/dev/null 2>&1; then
    rtk init -g --auto-patch >/dev/null 2>&1 || true
    echo "  [ok]      rtk init (hook + RTK.md + settings.json)"
  fi
fi

# --- rtk config (shared, symlinked) ----------------------------------------

echo ""
echo "=== rtk config ==="

# rtk reads its config via dirs::config_dir(); on macOS that resolves to
# ~/Library/Application Support/rtk/config.toml. We point a two-hop symlink
# chain at the shared repo file so edits propagate across devices:
#   ~/Library/Application Support/rtk/config.toml
#     -> ~/.config/rtk/config.toml
#       -> <repo>/claude/rtk-config.toml
RTK_CFG_SOURCE="$REPO_DIR/claude/rtk-config.toml"
RTK_XDG="$HOME/.config/rtk/config.toml"
RTK_MAC="$HOME/Library/Application Support/rtk/config.toml"

if [ ! -f "$RTK_CFG_SOURCE" ]; then
  echo "  [skip]    $RTK_CFG_SOURCE not found"
else
  # Idempotent symlink: link $1 (source) <- $2 (target); prompt before
  # clobbering a real (non-symlink) file. Mirrors the statusline logic above.
  link_rtk_config() {
    _src="$1"; _target="$2"; _label="$3"
    mkdir -p "$(dirname "$_target")"
    if [ -L "$_target" ]; then
      _cur=$(readlink "$_target")
      if [ "$_cur" = "$_src" ]; then
        echo "  [ok]      $_label (symlink already up to date)"
      else
        ln -sfn "$_src" "$_target"
        echo "  [updated] $_label -> $_src"
      fi
    elif [ -e "$_target" ]; then
      echo "  [skip]    $_label ($_target exists and is not a symlink)"
      printf "            Replace it with a symlink? [y/N] "
      read -r REPLY
      if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
        rm -f "$_target"
        ln -s "$_src" "$_target"
        echo "  [replaced] $_label -> $_src"
      else
        echo "            Skipped. Remove $_target manually and re-run."
      fi
    else
      ln -s "$_src" "$_target"
      echo "  [new]     $_label -> $_src"
    fi
  }

  link_rtk_config "$RTK_CFG_SOURCE" "$RTK_XDG" "~/.config/rtk/config.toml"
  link_rtk_config "$RTK_XDG" "$RTK_MAC" "~/Library/Application Support/rtk/config.toml"
fi

echo ""
echo "Done! Restart Claude Code to pick up changes."

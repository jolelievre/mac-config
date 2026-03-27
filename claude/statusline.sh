#!/bin/sh
# Claude Code custom status line
# Source: https://github.com/jLelievre/mac-config
# Reads JSON from stdin, outputs a single colored line
# Dir + git segments styled after jolimbo.zsh-theme (Powerline)

DATA=$(cat)

# Parse fields with jq (round floats to int in jq to avoid sh float issues)
MODEL=$(echo "$DATA" | jq -r '.model.display_name // ""')
EFFORT=$(echo "$DATA" | jq -r '.output_style.name // ""')
DIR=$(echo "$DATA" | jq -r '.workspace.current_dir // ""')
CTX_INT=$(echo "$DATA" | jq '[.context_window.used_percentage // 0] | .[0] | round')
RATE_5H=$(echo "$DATA" | jq '.rate_limits.five_hour.used_percentage // empty | round')
RATE_7D=$(echo "$DATA" | jq '.rate_limits.seven_day.used_percentage // empty | round')

# Foreground colors
RESET='\033[0m'
BOLD='\033[1m'
FG_BLACK='\033[30m'
FG_BLUE='\033[34m'
FG_GREEN='\033[32m'
FG_YELLOW='\033[33m'
FG_CYAN='\033[36m'
FG_RED='\033[31m'
DIM='\033[2m'

# Background colors
BG_BLUE='\033[44m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'

# Powerline characters (require a patched font)
SEP_ARROW='\xee\x82\xb0'   # U+E0B0
BRANCH_ICON='\xee\x82\xa0'  # U+E0A0

# Shorten directory: replace $HOME with ~
DIR=$(echo "$DIR" | sed "s|$HOME|~|")

# Git branch + dirty status
BRANCH=""
GIT_DIRTY=""
WORK_DIR=$(echo "$DATA" | jq -r '.workspace.current_dir // ""')
if [ -n "$WORK_DIR" ]; then
  BRANCH=$(git -C "$WORK_DIR" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$WORK_DIR" describe --tags --exact-match 2>/dev/null \
    || git -C "$WORK_DIR" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    # Check dirty status (staged + unstaged)
    STAGED=$(git -C "$WORK_DIR" diff --cached --name-only 2>/dev/null)
    UNSTAGED=$(git -C "$WORK_DIR" diff --name-only 2>/dev/null)
    MARKS=""
    [ -n "$STAGED" ] && MARKS="${MARKS}\xe2\x9c\x9a"
    [ -n "$UNSTAGED" ] && MARKS="${MARKS}\xe2\x97\x8f"
    [ -n "$STAGED" ] || [ -n "$UNSTAGED" ] && GIT_DIRTY="1"
  fi
fi

# Build a progress bar: usage: make_bar <percent>
# 10 chars wide, colored by threshold
make_bar() {
  pct=$1
  filled=$((pct / 10))
  empty=$((10 - filled))
  bar=""
  i=0; while [ "$i" -lt "$filled" ]; do bar="${bar}\xe2\x96\x88"; i=$((i + 1)); done
  i=0; while [ "$i" -lt "$empty"  ]; do bar="${bar}\xe2\x96\x91"; i=$((i + 1)); done
  if [ "$pct" -ge 80 ]; then color="$FG_RED"
  elif [ "$pct" -ge 50 ]; then color="$FG_YELLOW"
  else color="$FG_GREEN"
  fi
  printf '%s' "${color}${bar} ${pct}%${RESET}"
}

# Context color based on usage
if [ "$CTX_INT" -ge 80 ]; then
  CTX_COLOR="$FG_RED"
elif [ "$CTX_INT" -ge 50 ]; then
  CTX_COLOR="$FG_YELLOW"
else
  CTX_COLOR="$FG_GREEN"
fi

# Separator for non-Powerline segments
SEP="${DIM} | ${RESET}"

OUT=""

# --- Powerline segments: Dir + Git (matching jolimbo.zsh-theme) ---

# Directory segment: blue bg, black fg
OUT="${BG_BLUE}${FG_BLACK} ${DIR} "

# Transition to git segment or end Powerline
if [ -n "$BRANCH" ]; then
  if [ -n "$GIT_DIRTY" ]; then
    GIT_BG="$BG_YELLOW"
    GIT_ARROW_FG="$FG_YELLOW"
  else
    GIT_BG="$BG_GREEN"
    GIT_ARROW_FG="$FG_GREEN"
  fi
  # Arrow from blue to git bg
  OUT="${OUT}${GIT_BG}${FG_BLUE}${SEP_ARROW}${FG_BLACK} ${BRANCH_ICON} ${BRANCH}"
  [ -n "$MARKS" ] && OUT="${OUT} ${MARKS}"
  OUT="${OUT} ${RESET}${GIT_ARROW_FG}${SEP_ARROW}${RESET}"
else
  # No git: just close the blue segment
  OUT="${OUT}${RESET}${FG_BLUE}${SEP_ARROW}${RESET}"
fi

# --- Remaining segments (flat style) ---

# Rate limits (5h progress bar, 7d percent only)
if [ -n "$RATE_5H" ]; then
  R5_BAR=$(make_bar "$RATE_5H")
  RATE_STR="${DIM}5h${RESET} ${R5_BAR}"
  if [ -n "$RATE_7D" ]; then
    if [ "$RATE_7D" -ge 80 ]; then R7_COLOR="$FG_RED"
    elif [ "$RATE_7D" -ge 50 ]; then R7_COLOR="$FG_YELLOW"
    else R7_COLOR="$FG_GREEN"
    fi
    RATE_STR="${RATE_STR} ${DIM}7d${RESET} ${R7_COLOR}${RATE_7D}%${RESET}"
  fi
  OUT="${OUT}${SEP}${RATE_STR}"
fi

# Context (percent only)
OUT="${OUT}${SEP}${DIM}ctx${RESET} ${CTX_COLOR}${CTX_INT}%${RESET}"

# Model + effort (at the end)
if [ -n "$MODEL" ]; then
  OUT="${OUT}${SEP}${BOLD}${MODEL}${RESET}"
  [ -n "$EFFORT" ] && OUT="${OUT}${DIM} / ${RESET}${FG_CYAN}${EFFORT}${RESET}"
fi

printf '%b\n' "$OUT"

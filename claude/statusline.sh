#!/bin/sh
# Claude Code custom status line
# Source: https://github.com/jLelievre/mac-config
# Reads JSON from stdin, outputs a single colored line

DATA=$(cat)

# Parse fields with jq (round floats to int in jq to avoid sh float issues)
MODEL=$(echo "$DATA" | jq -r '.model.display_name // ""')
EFFORT=$(echo "$DATA" | jq -r '.output_style.name // ""')
DIR=$(echo "$DATA" | jq -r '.workspace.current_dir // ""')
CTX_INT=$(echo "$DATA" | jq '[.context_window.used_percentage // 0] | .[0] | round')
RATE_5H=$(echo "$DATA" | jq '.rate_limits.five_hour.used_percentage // empty | round')
RATE_7D=$(echo "$DATA" | jq '.rate_limits.seven_day.used_percentage // empty | round')

# Colors
RESET='\033[0m'
BOLD='\033[1m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
DIM='\033[2m'

# Shorten directory: replace $HOME with ~
DIR=$(echo "$DIR" | sed "s|$HOME|~|")

# Git branch
BRANCH=""
WORK_DIR=$(echo "$DATA" | jq -r '.workspace.current_dir // ""')
if [ -n "$WORK_DIR" ]; then
  BRANCH=$(git -C "$WORK_DIR" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$WORK_DIR" describe --tags --exact-match 2>/dev/null \
    || git -C "$WORK_DIR" rev-parse --short HEAD 2>/dev/null)
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
  if [ "$pct" -ge 80 ]; then color="$RED"
  elif [ "$pct" -ge 50 ]; then color="$YELLOW"
  else color="$GREEN"
  fi
  printf '%s' "${color}${bar} ${pct}%${RESET}"
}

# Context color based on usage
if [ "$CTX_INT" -ge 80 ]; then
  CTX_COLOR="$RED"
elif [ "$CTX_INT" -ge 50 ]; then
  CTX_COLOR="$YELLOW"
else
  CTX_COLOR="$GREEN"
fi

# Separator
SEP="${DIM} | ${RESET}"

OUT=""

# Directory
[ -n "$DIR" ] && OUT="${BLUE}${DIR}${RESET}"

# Git branch
[ -n "$BRANCH" ] && OUT="${OUT}${SEP}${MAGENTA}${BRANCH}${RESET}"

# Rate limits (5h progress bar, 7d percent only)
if [ -n "$RATE_5H" ]; then
  R5_BAR=$(make_bar "$RATE_5H")
  RATE_STR="${DIM}5h${RESET} ${R5_BAR}"
  if [ -n "$RATE_7D" ]; then
    if [ "$RATE_7D" -ge 80 ]; then R7_COLOR="$RED"
    elif [ "$RATE_7D" -ge 50 ]; then R7_COLOR="$YELLOW"
    else R7_COLOR="$GREEN"
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
  [ -n "$EFFORT" ] && OUT="${OUT}${DIM} / ${RESET}${CYAN}${EFFORT}${RESET}"
fi

printf '%b\n' "$OUT"

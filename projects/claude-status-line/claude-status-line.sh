#!/bin/sh
# Claude Code status line.
# Reads the Status JSON from stdin, prints two lines, always exits 0, never writes to stderr.
# Dependencies: POSIX sh + jq (+ awk for number formatting).

# ---------------------------------------------------------------------------
# Tunables
# ---------------------------------------------------------------------------
# Context window warning levels. A level is reached when the used percentage
# crosses its threshold, or (when CTX_CHECK_TOKENS=1) when the absolute token
# count crosses its threshold. Either condition is sufficient.
CTX_CHECK_TOKENS=1   # 1: check percentage AND token count, 0: percentage only
CTX_L1_PCT=40        # level 1 (yellow) at >= this percent ...
CTX_L1_TOKENS=120000  # ... or >= this many tokens (if CTX_CHECK_TOKENS=1)
CTX_L2_PCT=65        # level 2 (red, bold) at >= this percent ...
CTX_L2_TOKENS=200000 # ... or >= this many tokens (if CTX_CHECK_TOKENS=1)

# Rate limit (5h / 7d) usage percent at which the segment is highlighted.
LIMIT_WARN_PCT=90

# ---------------------------------------------------------------------------
# Colors (every colored segment is closed with RESET)
# ---------------------------------------------------------------------------
ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
CYAN="${ESC}[36m"
BMAGENTA="${ESC}[95m"
SEP=" ${DIM}│${RESET} "

exec 2>/dev/null
trap 'exit 0' EXIT

command -v jq >/dev/null 2>&1 || { printf 'statusline: jq not found\n'; exit 0; }

input=$(cat)
[ -n "$input" ] || exit 0

# One jq pass: extract raw values and pre-round numbers to integers so the
# shell only has to do integer comparisons. Missing values come out as "".
fields=$(printf '%s' "$input" | jq -r '
  def int: if . == null then null else (. + 0.5 | floor) end;
  def pick(f): (try f catch null) // "";
  [
    pick(.workspace.current_dir // .cwd),
    pick(.model.display_name // .model.id),
    pick(.effort.level),
    pick(.session_id),
    pick(.cost.total_cost_usd),
    pick(((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0))),
    pick(.context_window.used_percentage | int),
    pick(.context_window.context_window_size),
    pick(.context_window.current_usage
         | if . == null then null
           else ((.input_tokens // 0) + (.output_tokens // 0)
               + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) end),
    pick(.rate_limits.five_hour.used_percentage | int),
    pick(.rate_limits.seven_day.used_percentage | int)
  ] | map(tostring) | join("\u001f")
') || exit 0

old_ifs=$IFS
# Fields are joined with the ASCII unit separator (0x1f): unlike tab it is not
# IFS whitespace, so empty fields are preserved instead of being collapsed.
IFS=$(printf "\037")
# shellcheck disable=SC2086
set -- $fields
IFS=$old_ifs
cwd=$1; model=$2; effort=$3; session_id=$4; cost=$5
total_tokens=$6; ctx_pct=$7; ctx_size=$8; ctx_used=$9; five_pct=${10}; week_pct=${11}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
# 1234 -> 1.2k, 1234567 -> 1.2M
fmt_tokens() {
  n=$1
  if [ "$n" -ge 1000000 ]; then
    awk -v n="$n" 'BEGIN { printf "%.1fM", n / 1000000 }'
  elif [ "$n" -ge 1000 ]; then
    awk -v n="$n" 'BEGIN { printf "%.1fk", n / 1000 }'
  else
    printf '%s' "$n"
  fi
}

# append VAR SEGMENT: join SEGMENT to line VAR with the separator; skip empties.
append() {
  eval "cur=\$$1"
  [ -n "$2" ] || return 0
  if [ -n "$cur" ]; then eval "$1=\"\$cur\$SEP\$2\""; else eval "$1=\"\$2\""; fi
}

# ---------------------------------------------------------------------------
# Line 1: directory, model / effort, session id
# ---------------------------------------------------------------------------
line1=""

if [ -n "$cwd" ]; then
  case "$cwd" in
    "$HOME") cwd="~" ;;
    "$HOME"/*) cwd="~${cwd#"$HOME"}" ;;
  esac
  append line1 "${BOLD}${CYAN}${cwd}${RESET}"
fi

if [ -n "$model" ]; then
  seg="${BMAGENTA}${model}${RESET}"
  [ -n "$effort" ] && seg="${seg} ${DIM}/${RESET} ${BMAGENTA}${effort}${RESET}"
  append line1 "$seg"
fi

[ -n "$session_id" ] && append line1 "${DIM}sid${RESET} ${session_id}"

# ---------------------------------------------------------------------------
# Line 2: session tokens & cost, rate limits, context window
# ---------------------------------------------------------------------------
line2=""

seg=""
if [ -n "$total_tokens" ] && [ "$total_tokens" -gt 0 ]; then
  seg="${DIM}tok${RESET} $(fmt_tokens "$total_tokens")"
fi
if [ -n "$cost" ]; then
  cost_fmt=$(awk -v c="$cost" 'BEGIN { printf "$%.2f", c }')
  seg="${seg:+$seg  }${GREEN}${cost_fmt}${RESET}"
fi
append line2 "$seg"

# limit_seg LABEL PCT: plain by default, red + bold at/over LIMIT_WARN_PCT.
limit_seg() {
  [ -n "$2" ] || return 0
  if [ "$2" -ge "$LIMIT_WARN_PCT" ]; then
    printf '%s' "${BOLD}${RED}$1 $2%${RESET}"
  else
    printf '%s' "${DIM}$1${RESET} $2%"
  fi
}
seg=""
five=$(limit_seg 5h "$five_pct"); week=$(limit_seg 7d "$week_pct")
[ -n "$five" ] && seg="$five"
[ -n "$week" ] && seg="${seg:+$seg  }$week"
append line2 "$seg"

# Context window: omitted entirely when used_percentage is unavailable.
if [ -n "$ctx_pct" ]; then
  # Absolute usage: sum of current_usage counters, falling back to
  # percentage * window size right after a compact (current_usage is null).
  if [ -z "$ctx_used" ] && [ -n "$ctx_size" ]; then
    ctx_used=$(( ctx_pct * ctx_size / 100 ))
  fi
  : "${ctx_used:=0}"

  # at_or_above PCT TOKENS: true when the percentage threshold is reached, or
  # when token checking is enabled and the token threshold is reached.
  at_or_above() {
    [ "$ctx_pct" -ge "$1" ] && return 0
    [ "$CTX_CHECK_TOKENS" = 1 ] && [ "$ctx_used" -ge "$2" ]
  }

  level=0
  if at_or_above "$CTX_L2_PCT" "$CTX_L2_TOKENS"; then
    level=2
  elif at_or_above "$CTX_L1_PCT" "$CTX_L1_TOKENS"; then
    level=1
  fi

  case $level in
    2) seg="${BOLD}${RED}ctx ${ctx_pct}%${RESET}" ;;
    1) seg="${YELLOW}ctx ${ctx_pct}%${RESET}" ;;
    *) seg="${DIM}ctx${RESET} ${ctx_pct}%" ;;
  esac
  append line2 "$seg"
fi

[ -n "$line1" ] && printf '%s\n' "$line1"
[ -n "$line2" ] && printf '%s\n' "$line2"
exit 0

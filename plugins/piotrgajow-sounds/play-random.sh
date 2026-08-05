#!/usr/bin/env bash

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUNDS_DIR="$PLUGIN_ROOT/_sounds"
STATE_DIR="${HOME}/.cache/piotrgajow-sounds/dirs"
# A state file touched within this window means its voice pack is in use
ACTIVE_WINDOW_MIN=240
RELEASED_TIMESTAMP=202001010000

category=""
force_select=false
release=false
for arg in "$@"; do
  case "$arg" in
    --select) force_select=true ;;
    --release) release=true ;;
    *) category="$arg" ;;
  esac
done

mkdir -p "$STATE_DIR"

session_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
state_file="$STATE_DIR/$(printf '%s' "$session_dir" | tr '/' '.')"

select_pack() {
  local all used pool f
  all="$(find "$SOUNDS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)"

  used=""
  while IFS= read -r f; do
    [[ "$f" == "$state_file" ]] && continue
    used+="$(cat "$f" 2>/dev/null || true)"$'\n'
  done < <(find "$STATE_DIR" -type f -mmin "-$ACTIVE_WINDOW_MIN")
  used="$(printf '%s' "$used" | grep -v '^$' || true)"

  pool="$all"
  if [[ -n "$used" ]]; then
    pool="$(printf '%s\n' "$all" | grep -Fxv -f <(printf '%s\n' "$used") || true)"
  fi
  if [[ -z "$pool" ]]; then
    pool="$all"
  fi
  printf '%s\n' "$pool" | sort -R | head -n 1
}

if [[ -n "$category" ]]; then
  pack=""
  if [[ "$force_select" == false && -f "$state_file" ]]; then
    pack="$(cat "$state_file")"
  fi
  if [[ -z "$pack" || ! -d "$SOUNDS_DIR/$pack" ]]; then
    pack="$(select_pack)"
  fi
  printf '%s\n' "$pack" > "$state_file"

  sound_dir="$SOUNDS_DIR/$pack/$category"
  if [[ -d "$sound_dir" ]]; then
    random_file="$(find "$sound_dir" -maxdepth 1 -name '*.mp3' -type f | sort -R | head -n 1)"
    if [[ -n "$random_file" ]]; then
      set -m
      nohup afplay "$random_file" </dev/null >/dev/null 2>&1 &
    fi
  fi
fi

# Backdating (instead of deleting) frees the pack for other sessions while
# letting a concurrent session in the same directory keep using it
if [[ "$release" == true && -f "$state_file" ]]; then
  touch -t "$RELEASED_TIMESTAMP" "$state_file"
fi

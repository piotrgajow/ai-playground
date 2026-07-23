#!/usr/bin/env bash

set -euo pipefail

dir="$1"
random_file=$(find "$dir" -maxdepth 1 -name '*.mp3' -type f | sort -R | head -n 1)

if [[ -z "$random_file" ]]; then
  exit 0
fi

afplay "$random_file"

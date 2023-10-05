#!/bin/bash

arr_contains() {
  local target="$1"
  shift
  local array=("$@")
  local found=0

  for item in "${array[@]}"; do
    if [ "$item" = "$target" ]; then
      found=1
      break
    fi
  done

  echo $found
}

URL="https://api.open5e.com/v1/monsters/$1/"

# Start with the core that should work for all monsters
FILTER="$(cat './filters/core.jq')"

MONSTER="$(curl -s "$URL")"
SOURCE="$(echo "$MONSTER" | jq -r '.document__slug')"

kp_sources=("tob" "tob2" "tob3" "cc")

IS_KP_SOURCE=$(arr_contains  "$SOURCE" "${kp_sources[@]}")

if [[ "$SOURCE" == "menagerie" ]]; then
  MENAGERIE_SC="$(cat './filters/spellcasting/menagerie.jq')"
  FILTER="$FILTER"' '+' '"$MENAGERIE_SC"
fi

if [ "$IS_KP_SOURCE" -eq 1 ]; then
  KP_SC="$(cat './filters/spellcasting/kp.jq')"
  FILTER="$FILTER"' '+' '"$KP_SC"
fi

echo "$MONSTER" | jq --sort-keys --slurpfile skills skills.json "$FILTER"

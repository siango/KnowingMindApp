#!/usr/bin/env bash
set -euo pipefail
MAP="project_map.json"
JQ="${JQ_BIN:-jq}"
$JQ -r 'to_entries[] | .key + " " + .value.from' "$MAP" | while read -r key from; do
  if [ -d "$from" ]; then
    echo "✓ $key: found → $from"
  else
    echo "❌ $key: not found → $from"
  fi
done

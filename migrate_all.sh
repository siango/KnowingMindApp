#!/usr/bin/env bash
set -euo pipefail
MAP_FILE="${MAP_FILE:-project_map.json}"
JQ_BIN="${JQ_BIN:-jq}"

[[ -f "$MAP_FILE" ]] || { echo "ไม่พบ $MAP_FILE"; exit 1; }
PROJS=($($JQ_BIN -r 'keys[]' "$MAP_FILE"))

OK=(); FAIL=()
for p in "${PROJS[@]}"; do
  echo "=============================="
  echo "เริ่มย้ายโปรเจ็กต์: $p"
  if MAP_FILE="$MAP_FILE" bash ./migrate_project.sh "$p"; then
    OK+=("$p")
  else
    echo "❌ ล้มเหลว: $p"
    FAIL+=("$p")
  fi
done

echo "=============================="
echo "สรุป:"
echo "✅ สำเร็จ: ${OK[*]:-none}"
echo "❌ ล้มเหลว: ${FAIL[*]:-none}"
exit ${#FAIL[@]}

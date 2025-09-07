#!/usr/bin/env bash
set -euo pipefail
MAP="project_map.json"; JQ="${JQ_BIN:-jq}"

keys=($($JQ -r 'keys[]' "$MAP"))
for key in "${keys[@]}"; do
  cur_from="$($JQ -r ".\"$key\".from" "$MAP")"
  echo "======"
  echo "Project: $key"
  echo "Current from: $cur_from"
  read -rp "👉 ใส่พาธต้นทางจริง (เช่น /storage/emulated/0/Projects/$key) หรือกด Enter เพื่อข้าม: " NEWFROM
  if [[ -z "${NEWFROM:-}" ]]; then
    echo "  ↪ ข้าม $key"
    continue
  fi
  if [[ ! -d "$NEWFROM" ]]; then
    echo "  ❌ ไม่พบโฟลเดอร์: $NEWFROM  (ข้าม $key)"
    continue
  fi
  tmp="$(mktemp)"
  $JQ ".\"$key\".from = \"$NEWFROM\"" "$MAP" > "$tmp" && mv "$tmp" "$MAP"
  echo "  ✅ อัปเดตแล้ว -> $(jq -r ".\"$key\".from" "$MAP")"
done

echo "🎉 เสร็จสิ้นการอัปเดต paths"

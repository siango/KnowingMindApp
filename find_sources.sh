#!/usr/bin/env bash
set -euo pipefail
MAP="project_map.json"; JQ="${JQ_BIN:-jq}"

# โฟลเดอร์ฐานที่อยากค้นหา (เพิ่มได้ตามจริงของเครื่อง)
BASES=("$HOME" "/storage/emulated/0" "/sdcard" "/mnt" "/data/data/com.termux/files/home")

echo "🔎 Searching in: ${BASES[*]}"
$JQ -r 'keys[]' "$MAP" | while read -r key; do
  # เดาชื่อโฟลเดอร์จาก key (กำหนดเบื้องต้น)
  guess="$key"
  # map ชื่อพิเศษ
  case "$key" in
    beyond-the-rich) guess="ai|aimm|beyond|rich" ;;
    roblox-game)     guess="roblox" ;;
    anumodana-system) guess="anumodana|donation|foundation" ;;
    sati-finance)    guess="finance|cost|revenue" ;;
    content-automation) guess="automation|n8n|pipeline" ;;
  esac
  echo "------"
  echo "Project: $key (guess: $guess)"
  for base in "${BASES[@]}"; do
    # ค้นหาโฟลเดอร์ลึกไม่เกิน 4 ระดับ ชื่อมีคีย์เวิร์ด
    find "$base" -maxdepth 4 -type d \( -iregex ".*($guess).*" \) 2>/dev/null | head -n 5
  done
done

#!/usr/bin/env bash
# ย้ายโปรเจ็กต์เดียว: สำรอง → ย้าย → ตรวจเช็กพื้นฐาน
set -euo pipefail

usage(){ echo "ใช้: $0 <project_key> [--dry-run] [--no-backup]"; exit 1; }

JQ_BIN="${JQ_BIN:-jq}"
MAP_FILE="${MAP_FILE:-project_map.json}"
TS="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="${LOG_DIR:-$HOME/knowingmind-suite/_migration_logs}"
DRY_RUN=false
DO_BACKUP=true

[[ $# -lt 1 ]] && usage
PROJ="$1"; shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true;;
    --no-backup) DO_BACKUP=false;;
    *) echo "ออปชันไม่รู้จัก: $1"; usage;;
  esac
  shift
done

[[ -f "$MAP_FILE" ]] || { echo "ไม่พบ $MAP_FILE"; exit 1; }
FROM_RAW="$($JQ_BIN -r ".[\"$PROJ\"].from" "$MAP_FILE")"
TO_RAW="$($JQ_BIN -r ".[\"$PROJ\"].to" "$MAP_FILE")"
[[ "$FROM_RAW" == "null" || "$TO_RAW" == "null" ]] && { echo "ไม่มีคีย์ $PROJ ใน $MAP_FILE"; exit 1; }

eval "TO=\"$TO_RAW\""   # ขยาย $HOME ตอนนี้
FROM="$FROM_RAW"

[[ -d "$FROM" ]] || { echo "ที่มาไม่พบ: $FROM"; exit 1; }
mkdir -p "$TO" "$LOG_DIR"

echo "▶ ย้ายโปรเจ็กต์: $PROJ"
echo "   FROM: $FROM"
echo "   TO  : $TO"
echo "   DRY : $DRY_RUN  BACKUP: $DO_BACKUP"

# 1) สำรอง
if $DO_BACKUP; then
  BKP="$LOG_DIR/${PROJ}_backup_${TS}.tar.gz"
  echo "• สำรองเป็น: $BKP"
  $DRY_RUN || tar -C "$(dirname "$FROM")" -czf "$BKP" "$(basename "$FROM")"
fi

# 2) checksum ก่อนย้าย
SUM_BEFORE="$LOG_DIR/${PROJ}_before_${TS}.sha256"
echo "• สร้าง checksum ก่อนย้าย → $SUM_BEFORE"
$DRY_RUN || (cd "$FROM" && find . -maxdepth 10 -type f -print0 | sort -z | xargs -0 sha256sum > "$SUM_BEFORE")

# 3) rsync ย้าย
echo "• ย้ายไฟล์ด้วย rsync"
RSYNC_FLAGS="-a --delete --human-readable --exclude node_modules --exclude .git"
$DRY_RUN || rsync $RSYNC_FLAGS "$FROM/." "$TO/"

# 4) checksum หลังย้าย & เทียบ
SUM_AFTER="$LOG_DIR/${PROJ}_after_${TS}.sha256"
echo "• สร้าง checksum หลังย้าย → $SUM_AFTER"
$DRY_RUN || (cd "$TO" && find . -maxdepth 10 -type f -print0 | sort -z | xargs -0 sha256sum > "$SUM_AFTER")

if ! $DRY_RUN; then
  echo "• ตรวจเทียบ checksum"
  diff -u "$SUM_BEFORE" "$SUM_AFTER" > "$LOG_DIR/${PROJ}_diff_${TS}.txt" || true
  if grep -qE '^[+-][0-9a-f]{64}' "$LOG_DIR/${PROJ}_diff_${TS}.txt"; then
    echo "⚠ พบความต่างไฟล์ (ดู diff ที่ $LOG_DIR/${PROJ}_diff_${TS}.txt)"
  else
    echo "✓ ไฟล์ตรงกันหลังย้าย"
  fi
fi

# 5) smoke test
if [[ -f "$TO/package.json" ]]; then
  echo "• ตรวจ npm (lint/build) ใน $TO"
  if [[ -f "$TO/package-lock.json" ]]; then
    PMCMD="npm ci --silent"
  else
    PMCMD="npm install --no-audit --no-fund --silent"
  fi
  if ! $DRY_RUN; then
    (cd "$TO" && ( $PMCMD || true ); \
      (jq -er '.scripts.lint' package.json >/dev/null 2>&1 && npm run -s lint || true); \
      (jq -er '.scripts.build' package.json >/dev/null 2>&1 && npm run -s build || true)
    )
  fi
elif [[ -d "$TO/src" && "$PROJ" == "roblox-game" ]]; then
  echo "• Roblox โปรเจ็กต์: ตรวจไฟล์หลัก src/*"
  $DRY_RUN || (test -f "$TO/src/ReplicatedStorage/Config/Rewards.lua" && test -f "$TO/src/ServerScriptService/DataStore.server.lua" && echo "✓ ไฟล์หลักครบ")
else
  echo "• ไม่มีสคริปต์ build เฉพาะ ข้ามการ build"
fi

echo "✅ เสร็จสิ้นการย้าย: $PROJ"

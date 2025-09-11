#!/usr/bin/env bash
# termux/ost_single.sh — run one-shot for a single device
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "${DIR}/common/termux_lib.sh"

DEV=""
for i in "$@"; do
  case "$i" in
    --device) shift; DEV="${1:-}"; shift || true ;;
    --device=*) DEV="${i#*=}" ;;
  esac
done

[ -n "$DEV" ] || err "ใช้: $0 --device <device_id>"

F="${DIR}/devices/${DEV}.yaml"
[ -f "$F" ] || err "ไม่พบไฟล์: $F"

ensure_base

OS=$(yaml_get "$F" '.os')
HOST_EXPECT=$(yaml_get "$F" '.hostname_expect')
REPO_URL=$(yaml_get "$F" '.repo.url')
REPO_PATH=$(yaml_get "$F" '.repo.path')
REPO_BRANCH=$(yaml_get "$F" '.repo.branch')

# 1) hostname guard (ถ้ากำหนดไว้)
HOST_NOW=$(getprop ro.product.model 2>/dev/null || hostname || echo "unknown")
if [ -n "$HOST_EXPECT" ] && [ "$HOST_EXPECT" != "null" ]; then
  if ! printf "%s" "$HOST_NOW" | grep -qi "$HOST_EXPECT"; then
    write_matrix "$DEV" "❌" "hostname mismatch: expect=$HOST_EXPECT, got=$HOST_NOW"
    err "hostname mismatch"
  fi
fi

# 2) sync repo
git_sync "$REPO_URL" "$REPO_PATH" "$REPO_BRANCH"

# 3) sample: pull secrets (optional demo)
KMA_API_KEY="$(get_secret KMA_API_KEY)"
# (ใช้จริงในขั้นตอน config ถัดไปได้)

# 4) cron setup (append if not exists)
if [ -f "$F" ]; then
  mapfile -t lines < <(yq -r '.cron[]?' "$F" 2>/dev/null || true)
  if [ "${#lines[@]}" -gt 0 ]; then
    for c in "${lines[@]}"; do
      (crontab -l 2>/dev/null | grep -F "$c" >/dev/null) || (crontab -l 2>/dev/null; echo "$c") | crontab -
    done
  fi
fi

# 5) health check sample (customizeตามระบบจริง)
NOTE=$(health_check "https://knowingmindproject.website" | tr -d '\r')
STATUS="✅"; [ -z "$NOTE" ] && STATUS="⚠"; [ -z "$NOTE" ] && NOTE="no response"
write_matrix "$DEV" "$STATUS" "$NOTE"

ok "เสร็จ: $DEV"
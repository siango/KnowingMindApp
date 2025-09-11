#!/usr/bin/env bash
# common/termux_lib.sh — helpers for multi-device one-shot
set -euo pipefail

say(){ printf "%b\n" "$*"; }
ok(){ say "✓ $*"; }
warn(){ say "⚠ $*"; }
err(){ say "❌ $*"; exit 1; }

need(){ command -v "$1" >/dev/null 2>&1 || { warn "ต้องติดตั้ง: $1"; return 1; }; }

ensure_base() {
  pkg update -y >/dev/null 2>&1 || true
  pkg install -y git curl jq yq coreutils >/dev/null 2>&1 || true
}

yaml_get(){ # yaml_get file keypath (yq)
  local f="$1" k="$2"
  yq -r "$k" "$f"
}

git_sync(){
  local url="$1" path="$2" branch="$3"
  mkdir -p "$(dirname "$path")"
  if [ ! -d "$path/.git" ]; then
    git clone --depth 1 -b "$branch" "$url" "$path"
  else
    (cd "$path" && git fetch --depth 1 origin "$branch" && git checkout "$branch" && git pull --ff-only)
  fi
}

get_secret(){
  local key="$1"
  if [ -x "${HOME}/.secrets_toolkit/get_secret.sh" ]; then
    "${HOME}/.secrets_toolkit/get_secret.sh" "$key"
  else
    echo ""
  fi
}

health_check(){
  local url="$1" timeout="${2:-8}"
  curl -sS --max-time "$timeout" -I "$url" | head -n1 || true
}

write_matrix(){
  local device="$1" status="$2" note="$3"
  local file="$(cd "$(dirname "$0")/../checks" && pwd)/health_matrix.md"
  if ! grep -q '^| Device' "$file" 2>/dev/null; then
    printf "| Device | Status | Note |\n|---|---|---|\n" > "$file"
  fi
  printf "| %s | %s | %s |\n" "$device" "$status" "$note" >> "$file"
}
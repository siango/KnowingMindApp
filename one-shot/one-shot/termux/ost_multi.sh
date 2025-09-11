#!/usr/bin/env bash
# termux/ost_multi.sh — run one-shot for all/selected devices
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEL=""
ALL=0

for i in "$@"; do
  case "$i" in
    --only) shift; SEL="${1:-}"; shift || true ;;
    --only=*) SEL="${i#*=}" ;;
    --all|--ALL) ALL=1; shift || true ;;
  esac
done

if [ "$ALL" -ne 1 ] && [ -z "$SEL" ]; then
  echo "ใช้: $0 --all | --only <device_id>"
  exit 2
fi

run_one(){
  local dev="$1"
  bash "${DIR}/termux/ost_single.sh" --device "$dev" || true
}

if [ "$ALL" -eq 1 ]; then
  for f in "${DIR}/devices/"*.yaml; do
    dev="$(basename "$f" .yaml)"
    run_one "$dev"
  done
else
  run_one "$SEL"
fi
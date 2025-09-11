#!/usr/bin/env bash
# ost_multi.sh — run setup on all devices or a chosen one
set -euo pipefail
ROOT=$(dirname "$0")/..
. "$ROOT/common/termux_lib.sh"

DEVICE_DIR="$ROOT/devices"

usage(){ echo "Usage: $0 [--all | --only <device_id>]"; exit 1; }

ALL=false; ONLY=""
case "${1:-}" in
  --all) ALL=true ;;
  --only) ONLY=$2 ;;
  *) usage ;;
esac

for file in $DEVICE_DIR/*.yaml; do
  id=$(basename $file .yaml)
  if $ALL || [ "$id" = "$ONLY" ]; then
    echo "==> Running for $id"
    # parse config (basic demo: just print)
    grep '^device_id' $file
    # TODO: implement sync/health using termux_lib.sh
  fi
done

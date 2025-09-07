#!/usr/bin/env bash
set -euo pipefail
pids=()
cleanup(){ echo; echo "Stopping..."; for p in "${pids[@]}"; do kill "$p" 2>/dev/null || true; done; wait || true; }
trap cleanup INT TERM

mapfile -t SERVS < <(find services -maxdepth 1 -mindepth 1 -type d | sort)
for s in "${SERVS[@]}"; do
  if [ -f "$s/package.json" ] && node -e "try{p=require('./$s/package.json');process.exit(p.scripts&&p.scripts.dev?0:1)}catch(e){process.exit(1)}"; then
    echo "▶ $s: npm run dev"
    (cd "$s" && npm run -s dev) & pids+=($!)
  else
    echo "• $s: (no dev script)"
  fi
done

echo "All services launched. Press Ctrl+C to stop."
wait

#!/usr/bin/env bash
set -euo pipefail
echo "== Fix lock & npm install =="
mapfile -t DIRS < <(find apps services -maxdepth 2 -type f -name package.json -printf '%h\n' 2>/dev/null | sort -u)
for d in "${DIRS[@]}"; do
  echo "=== $d ==="
  cd "$d"
  rm -f package-lock.json
  npm install --no-audit --no-fund || true
  # run only if script exists
  node -e "try{p=require('./package.json');process.exit(p.scripts&&p.scripts.lint?0:1)}catch(e){process.exit(1)}" && npm run -s lint || echo "(no lint)"
  node -e "try{p=require('./package.json');process.exit(p.scripts&&p.scripts.build?0:1)}catch(e){process.exit(1)}" && npm run -s build || echo "(no build)"
  cd - >/dev/null
done
echo "== Done =="

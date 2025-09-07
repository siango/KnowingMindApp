#!/usr/bin/env bash
set -euo pipefail
./check_sources.sh || true
bash ./migrate_all.sh || true
bash ./verify_post_migration.sh "$HOME/knowingmind-suite" || true
cd "$HOME/knowingmind-suite/_migration_logs"
for f in *_diff_*.txt; do
  if grep -qE '^[+-][0-9a-f]{64}' "$f"; then
    echo "⚠ $f มีความต่าง"
  fi
done
echo "== Done =="

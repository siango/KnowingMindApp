#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$HOME/knowingmind-suite}"

declare -a EXPECT_APPS=(
  "apps/kma" "apps/arunroo" "apps/satishift" "apps/beyond-the-rich" "apps/roblox-game"
  "apps/foundation-admin" "apps/impact-dashboard" "apps/creator-studio"
  "apps/anumodana-system" "apps/sati-finance"
)
for d in "${EXPECT_APPS[@]}"; do
  [[ -d "$ROOT/$d" ]] && echo "✓ $d" || { echo "❌ ขาด $d"; MISS=1; }
done

for p in ui core-schemas sdk-client auth-kit avatar-engine coins-ledger dharma-snippets feature-flags; do
  [[ -d "$ROOT/packages/$p" ]] && echo "✓ packages/$p" || { echo "❌ ขาด packages/$p"; MISS=1; }
done

for s in gateway identity journal ledger donation projects analytics moderation; do
  [[ -d "$ROOT/services/$s" ]] && echo "✓ services/$s" || { echo "❌ ขาด services/$s"; MISS=1; }
done

for port in 8080 8081 8082; do
  if command -v nc >/dev/null 2>&1 && nc -z localhost "$port" 2>/dev/null; then
    echo "• curl /healthz :$port"
    curl -sf "http://localhost:$port/healthz" && echo "✓ OK $port" || echo "⚠ healthz ล้มเหลว $port"
  fi
done

exit ${MISS:-0}

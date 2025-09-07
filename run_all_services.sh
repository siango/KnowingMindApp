#!/usr/bin/env bash
set -euo pipefail
RETRY=${RETRIES:-120}; SLEEP=${SLEEP:-0.5}; DO_BOOTSTRAP=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --retries) RETRY="$2"; shift 2;;
    --sleep)   SLEEP="$2"; shift 2;;
    --no-bootstrap) DO_BOOTSTRAP=0; shift;;
    *) echo "unknown arg: $1"; exit 1;;
  esac
done
declare -A PORTS=([gateway]=3100 [identity]=3101 [journal]=3102 [ledger]=3103 [donation]=3104 [analytics]=3105 [moderation]=3106)
SERVS=(gateway identity journal ledger donation analytics moderation)

find_root(){ local d="$PWD"; while [[ "$d" != "/" ]]; do [[ -d "$d/services" ]] && { echo "$d"; return; }; d="$(dirname "$d")"; done; [[ -d "$HOME/knowingmind-suite/services" ]] && { echo "$HOME/knowingmind-suite"; return; }; return 1; }
ROOT="$(find_root)" || { echo "❌ cannot find repo root (needs ./services)"; exit 1; }
cd "$ROOT"; mkdir -p _logs

bootstrap_service(){
  local s="$1" dir="services/$s"; mkdir -p "$dir/src"
  cat > "$dir/src/healthz.js" <<JS
module.exports = function healthz(app, serviceName='${s}') {
  app.get('/healthz', (req, res) => { res.status(200).json({ ok: true, service: serviceName, ts: Date.now() }); });
};
JS
  if [[ ! -f "$dir/server.js" ]]; then
    cat > "$dir/server.js" <<JS
const express = require('express');
const app = express();
const healthz = require('./src/healthz');
healthz(app, '${s}');
const port = process.env.PORT || ${PORTS[$s]};
app.listen(port, () => console.log('[${s}] listening on ' + port));
JS
  fi
  if [[ -f "$dir/package.json" ]]; then
    node -e "const fs=require('fs');const p='$dir/package.json';const pkg=JSON.parse(fs.readFileSync(p,'utf8'));pkg.scripts=pkg.scripts||{};pkg.scripts.dev='node server.js';pkg.dependencies=pkg.dependencies||{};pkg.dependencies.express=pkg.dependencies.express||'^4.19.2';fs.writeFileSync(p,JSON.stringify(pkg,null,2));"
  else
    cat > "$dir/package.json" <<JSON
{ "name":"${s}", "version":"0.1.0", "private":true, "scripts":{"dev":"node server.js"}, "dependencies":{"express":"^4.19.2"} }
JSON
  fi
  [[ -d "$dir/node_modules/express" ]] || (cd "$dir" && npm install --no-audit --no-fund >/dev/null 2>&1 || true)
}

echo "▶ Working dir: $ROOT"
if [[ "$DO_BOOTSTRAP" -eq 1 ]]; then
  echo "▶ Bootstrap services (safe & idempotent)"
  for s in "${SERVS[@]}"; do bootstrap_service "$s"; done
fi

pids=()
cleanup(){ echo; echo "Stopping all..."; for p in "${pids[@]}"; do kill "$p" 2>/dev/null || true; done; wait || true; }
trap cleanup INT TERM

echo "▶ Launching services (logs → ./_logs/<service>.log)"
for s in "${SERVS[@]}"; do
  dir="services/$s"; log="_logs/${s}.log"
  echo "• $s :${PORTS[$s]}  → $log"
  (cd "$dir" && PORT="${PORTS[$s]}" npm run -s dev) >>"$log" 2>&1 & pids+=($!)
done

echo "⏳ Waiting for health checks (retries=$RETRY, sleep=${SLEEP}s)"
declare -A UP; for s in "${SERVS[@]}"; do UP["$s"]=0; done
for ((i=1;i<=RETRY;i++)); do
  done_count=0
  for s in "${SERVS[@]}"; do
    [[ ${UP[$s]} -eq 1 ]] && { ((done_count++)); continue; }
    port="${PORTS[$s]}"
    if curl -fsS "http://127.0.0.1:$port/healthz" >/dev/null 2>&1; then
      UP["$s"]=1; echo "✓ $s up (:${port})"; ((done_count++))
    fi
  done
  [[ $done_count -eq ${#SERVS[@]} ]] && break
  sleep "$SLEEP"
done

ok=0; fail=0
echo "──────── Summary ────────"
for s in "${SERVS[@]}"; do
  if [[ ${UP[$s]} -eq 1 ]]; then echo "✓ $s (:${PORTS[$s]})"; ((ok++)); else echo "✗ $s (:${PORTS[$s]}) — see _logs/${s}.log"; ((fail++)); fi
done
echo "Total: $ok up, $fail down"
echo "▶ All services running. Ctrl+C to stop."
wait

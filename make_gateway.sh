#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"; shift || true
WEBHOOK_URL="${WEBHOOK_URL:-}"
API_BASE="${API_BASE:-https://us1.make.com/api/v2}"
API_KEY="${API_KEY:-}"
SCENARIO_ID="${SCENARIO_ID:-}"
JSON_DATA="${JSON_DATA:-}"

case "$MODE" in
  webhook)
    [ -z "$WEBHOOK_URL" ] && { echo "WEBHOOK_URL required"; exit 1; }
    curl -sS -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d "${JSON_DATA:-{}}"
    ;;
  start)
    [ -z "$API_KEY" -o -z "$SCENARIO_ID" ] && { echo "API_KEY & SCENARIO_ID required"; exit 1; }
    curl -sS -X POST "$API_BASE/scenarios/$SCENARIO_ID/start" -H "Authorization: $API_KEY"
    ;;
  stop)
    [ -z "$API_KEY" -o -z "$SCENARIO_ID" ] && { echo "API_KEY & SCENARIO_ID required"; exit 1; }
    curl -sS -X POST "$API_BASE/scenarios/$SCENARIO_ID/stop" -H "Authorization: $API_KEY"
    ;;
  run)
    [ -z "$API_KEY" -o -z "$SCENARIO_ID" ] && { echo "API_KEY & SCENARIO_ID required"; exit 1; }
    curl -sS -X POST "$API_BASE/scenarios/$SCENARIO_ID/run" -H "Authorization: $API_KEY" -H "Content-Type: application/json" -d "${JSON_DATA:-{\"responsive\":true,\"data\":{}}}"
    ;;
  *)
    echo "Usage: $0 {webhook|start|stop|run}"
    ;;
esac

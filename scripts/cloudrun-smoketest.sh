\
    #!/usr/bin/env bash
    set -euo pipefail
    declare -A BASE=(
      ["arunroo-ics"]="https://arunroo-ics-610232224779.asia-southeast1.run.app"
      ["satishift-webhook"]="https://satishift-webhook-610232224779.asia-southeast1.run.app"
      ["kma-api"]="https://kma-api-610232224779.asia-southeast1.run.app" # may be internal-only
    )
    SERVICES=("arunroo-ics" "satishift-webhook" "kma-api")
    PATHS=("/" "/api/ping" "/health")

    for svc in "${SERVICES[@]}"; do
      base="${BASE[$svc]:-}"
      if [[ -z "$base" ]]; then echo "[skip] $svc no base url"; continue; fi
      echo "== $svc ($base)"
      for p in "${PATHS[@]}"; do
        url="$base$p"
        if curl -sSf -m 8 "$url" >/dev/null; then
          echo "  $url -> OK"
        else
          echo "  $url -> FAILED"
        fi
      done
      echo
    done

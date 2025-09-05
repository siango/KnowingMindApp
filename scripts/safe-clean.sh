\
    #!/usr/bin/env bash
    # Safe clean workspace (dry-run by default)
    set -euo pipefail
    ROOT="${1:-.}"
    DAYS="${2:-30}"
    EXECUTE="${3:-false}" # "true" to actually delete

    echo "== SafeClean: $ROOT  (older than $DAYS days)"
    mapfile -t DIRS < <(printf "%s\n" ".git" ".gradle" ".idea" "build" "dist" "out" ".angular" "coverage" ".next" ".vite" "target" "node_modules" "pnpm-store")
    mapfile -t FILES < <(find "$ROOT" -type f -mtime "+$DAYS" \( -name "*.log" -o -name "*.tmp" -o -name "*.bak" -o -name "*.old" -o -name "*.cache" \))

    echo "-- Candidates (directories):"
    for d in "${DIRS[@]}"; do
      find "$ROOT" -type d -name "$d" -prune -print
    done

    echo "-- Candidates (files):"
    printf "%s\n" "${FILES[@]}"

    if [[ "$EXECUTE" == "true" ]]; then
      echo "Executing deletion..."
      # Delete dirs
      for d in "${DIRS[@]}"; do
        find "$ROOT" -type d -name "$d" -prune -exec rm -rf {} + 2>/dev/null || true
      done
      # Delete files
      if [[ "${#FILES[@]}" -gt 0 ]]; then
        printf "%s\0" "${FILES[@]}" | xargs -0 rm -f 2>/dev/null || true
      fi
      echo "Done."
    else
      echo "Dry-run only. Pass third arg 'true' to actually delete."
    fi

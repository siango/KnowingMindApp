#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="${1:-.}"
cd "$REPO_DIR"
OUT="ARUNROO_GIT_REPORT_$(date +%Y%m%d_%H%M%S).md"
echo "# ArunRoo — Git Audit Report" | tee "$OUT"
echo "_Generated: $(date -u +'%Y-%m-%dT%H:%M:%SZ') (UTC)_" | tee -a "$OUT"
echo | tee -a "$OUT"
echo "## 1) Remotes" | tee -a "$OUT"
git remote -v | sed 's/^/- /' | tee -a "$OUT"
echo | tee -a "$OUT"
main_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || echo "main")
[[ -z "$main_branch" ]] && main_branch="main"
echo "## 2) Fetch + prune" | tee -a "$OUT"
git fetch --all --prune 2>&1 | sed 's/^/    /' | tee -a "$OUT"
echo | tee -a "$OUT"
echo "## 3) Status" | tee -a "$OUT"
git status -sb | sed 's/^/    /' | tee -a "$OUT"
echo | tee -a "$OUT"
echo "## 4) Graph (50 commits)" | tee -a "$OUT"
git log --graph --decorate --oneline --all -n 50 | sed 's/^/    /' | tee -a "$OUT"
echo | tee -a "$OUT"
echo "## 5) Branches by activity" | tee -a "$OUT"
git for-each-ref --sort=-committerdate --format='%(refname:short) | %(committerdate:relative) | %(authorname)' refs/heads/ | sed 's/^/    /' | tee -a "$OUT"
echo | tee -a "$OUT"
echo "## 6) Ahead/Behind vs origin/${main_branch}" | tee -a "$OUT"
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
  ab="$(git rev-list --left-right --count origin/${main_branch}...${b} 2>/dev/null || echo '0 0')"
  echo "    $b  <=(ahead/behind)=> origin/${main_branch}: $ab" | tee -a "$OUT"
done
echo | tee -a "$OUT"
echo "## 7) Unmerged branches → ${main_branch}" | tee -a "$OUT"
git branch --no-merged "${main_branch}" | sed 's/^/    /' | tee -a "$OUT" || true
echo | tee -a "$OUT"
echo "## 8) Contributors (30 days)" | tee -a "$OUT"
git shortlog -sne --since='30 days ago' | sed 's/^/    /' | tee -a "$OUT" || true
echo | tee -a "$OUT"
echo "## 9) Files changed (14 days)" | tee -a "$OUT"
git log --since='14 days ago' --name-only --pretty=format: | sort -u | sed 's/^/    /' | tee -a "$OUT" || true
echo | tee -a "$OUT"
echo "## 10) TODO/FIXME" | tee -a "$OUT"
( command -v rg >/dev/null && rg -n --hidden -S 'TODO|FIXME' || grep -RInE 'TODO|FIXME' . --exclude-dir=.git ) | sed 's/^/    /' | tee -a "$OUT" || true
echo | tee -a "$OUT"
echo "## 11) Key modules presence" | tee -a "$OUT"
for p in docs brand_kit content scheduler calendar gsheets_kit_v2 n8n_workflows .github; do
  [[ -e "$p" ]] && echo "    ✅ $p" | tee -a "$OUT" || echo "    ❌ $p" | tee -a "$OUT"
done
echo | tee -a "$OUT"
echo "## 12) Next actions" | tee -a "$OUT"
cat <<'TXT' | sed 's/^/    /' | tee -a "$OUT"
- Merge/rebase stale branches; prune merged
- Finish Readcast (TTS→Host→Promo)
- Swap YouTube HTTP→YouTube Node in n8n
- Add CI for YAML/JSON schema
- Tag v0.5 when Readcast MVP is live
TXT
echo
echo "Report written to: $OUT"

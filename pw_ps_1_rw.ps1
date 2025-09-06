# =============================
# pw.ps1  — Pause & snapshot to wip/YYYYMMDD-HHmm, commit, push
# Requirements: git, optional GITHUB_TOKEN (fine‑grained PAT)
# Install: save to $HOME\bin\pw.ps1 (or $HOME\KMS\bin), ensure folder is in PATH
# Usage: from any folder inside your repo → pw
# =============================
param(
  [string]$Message = "Pause-Work snapshot"
)

function Fail($m){ Write-Error $m; exit 1 }
function Ok($m){ Write-Host "✔ $m" -ForegroundColor Green }

# 1) Ensure we are inside a git repo & get root
$gitTop = (git rev-parse --show-toplevel) 2>$null
if (-not $gitTop) { Fail "Not inside a git repository." }
Set-Location $gitTop

# 2) Ensure working tree exists; stage everything
& git add -A | Out-Null

# 3) Create timestamped wip branch name
$ts = Get-Date -Format "yyyyMMdd-HHmm"
$branch = "wip/$ts"

# 4) Commit (allow empty to force snapshot)
& git commit --allow-empty -m "$Message ($branch)" | Out-Null
Ok "Committed snapshot on $(git rev-parse --abbrev-ref HEAD)"

# 5) Create branch pointer for this snapshot
# Use a lightweight tag-like branch for easy resume history.
& git branch $branch | Out-Null
Ok "Created branch $branch pointing to snapshot"

# 6) Push with optional token (works with or without credential manager)
$extra = @()
if ($env:GITHUB_TOKEN -and $env:GITHUB_TOKEN.Length -ge 20) {
  $extra = @('-c', "http.extraheader=Authorization: Bearer $($env:GITHUB_TOKEN)")
}
& git @extra push -u origin $branch 2>&1 | Write-Host
Ok "Pushed to origin/$branch"

# 7) Print resume hint
Write-Host "➡ To resume later: rw" -ForegroundColor Cyan

# =============================
# rw.ps1 — Resume: checkout latest origin/wip/* and pull
# Requirements: git, optional GITHUB_TOKEN
# Install: save to $HOME\bin\rw.ps1 (or $HOME\KMS\bin)
# Usage: from any folder inside your repo → rw
# =============================
# (Keep both scripts in the same file for review; save as separate files when installing.)
# ----- START rw.ps1 CONTENT -----
# You can split below into its own file $HOME\bin\rw.ps1

# ^^^ remove lines above when splitting files

# Detect repo
$gitTop2 = (git rev-parse --show-toplevel) 2>$null
if (-not $gitTop2) { Fail "Not inside a git repository." }
Set-Location $gitTop2

# Fetch with optional token
$extra2 = @()
if ($env:GITHUB_TOKEN -and $env:GITHUB_TOKEN.Length -ge 20) {
  $extra2 = @('-c', "http.extraheader=Authorization: Bearer $($env:GITHUB_TOKEN)")
}
& git @extra2 fetch --all --prune 2>&1 | Write-Host

# Find newest origin/wip/* by name (timestamp ordering)
$latest = git for-each-ref --format="%(refname:short)" refs/remotes/origin/wip | Sort-Object -Descending | Select-Object -First 1
if (-not $latest) { Fail "No remote branches under origin/wip/* found." }
Ok "Latest remote WIP: $latest"

# Derive local branch name
$local = $latest -replace '^origin/', ''

# Checkout local tracking branch at that ref
& git checkout -B $local $latest 2>&1 | Write-Host
& git @extra2 pull 2>&1 | Write-Host
Ok "Checked out and updated $local"

# Print hint
Write-Host "✔ Ready to continue work on $local" -ForegroundColor Green

# ----- END rw.ps1 CONTENT -----

# =============================
# Quick notes (put in README if needed)
# =============================
# • Place pw.ps1 and rw.ps1 into $HOME\bin and add that folder to PATH (User PATH).
# • Both scripts honor $env:GITHUB_TOKEN for HTTPS push/pull if credential manager isn’t set.
# • pw creates a timestamped branch wip/YYYYMMDD-HHmm from current HEAD and pushes it.
# • rw fetches and checks out the lexicographically newest origin/wip/* branch.
# • For repos using SSH remotes, omit token; scripts still work with your existing auth.

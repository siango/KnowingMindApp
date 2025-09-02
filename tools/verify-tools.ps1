#Requires -Version 5.1
<#
  Verifies repo tooling & conventions:
  - Required files exist
  - git-wip functions/aliases load
  - .gitattributes LF policy
  - core.autocrlf off (advisory)
  - PR template exists
  - sync-docs & checksum scripts present
  Exits 0 on success, 1 on failure
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$fail = @()
$warn = @()
$ok   = @()

function Add-Fail([string]$msg){ $global:fail += $msg; Write-Host "❌ $msg" -ForegroundColor Red }
function Add-Warn([string]$msg){ $global:warn += $msg; Write-Host "⚠  $msg" -ForegroundColor Yellow }
function Add-Ok  ([string]$msg){ $global:ok   += $msg; Write-Host "✅ $msg" -ForegroundColor Green }

# Ensure in repo
$repoRoot = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) {
  Add-Fail "Not inside a git repository."
  exit 1
}
Set-Location $repoRoot

# 1) Required files
$required = @(
  "tools/git-wip.ps1",
  "tools/sync-docs.ps1",
  "tools/security/CHECKSUM_baseline.ps1",
  "tools/security/CHECKSUM_verify.ps1",
  "tools/security/BACKUP_robocopy.ps1",
  "tools/security/WINDOWS_UPDATE_notify_only_instructions.md",
  ".github/PULL_REQUEST_TEMPLATE.md"
)

foreach($f in $required){
  if(Test-Path $f){ Add-Ok "$f found" } else { Add-Fail "$f missing" }
}

# 2) git-wip functions / aliases
try {
  . "tools/git-wip.ps1"
  if (Get-Command Pause-Work -ErrorAction SilentlyContinue) { Add-Ok "Function Pause-Work available" } else { Add-Fail "Function Pause-Work missing" }
  if (Get-Command Resume-Work -ErrorAction SilentlyContinue) { Add-Ok "Function Resume-Work available" } else { Add-Fail "Function Resume-Work missing" }
  if (Get-Alias pw -ErrorAction SilentlyContinue) { Add-Ok "Alias pw set" } else { Add-Warn "Alias pw not set (not critical if functions exist)" }
  if (Get-Alias rw -ErrorAction SilentlyContinue) { Add-Ok "Alias rw set" } else { Add-Warn "Alias rw not set (not critical if functions exist)" }
}
catch {
  Add-Fail "Failed to dot-source tools/git-wip.ps1: $($_.Exception.Message)"
}

# 3) .gitattributes checks (LF policy + no LFS mp3)
$gaPath = ".gitattributes"
if (Test-Path $gaPath) {
  $ga = Get-Content $gaPath -Raw
  if ($ga -match "(?im)^\*\s+text=auto\s+eol=lf") { Add-Ok ".gitattributes: * text=auto eol=lf found" }
  else { Add-Warn ".gitattributes: 'text=auto eol=lf' not found on wildcard rule" }
  if ($ga -match "(?im)^\*\.ps1\s+.*eol=lf") { Add-Ok ".gitattributes: *.ps1 eol=lf" } else { Add-Warn ".gitattributes: missing '*.ps1 eol=lf'" }
  if ($ga -notmatch "(?im)\*\.mp3\s+.*filter=lfs") { Add-Ok ".gitattributes: no LFS rule for *.mp3 (as intended)" }
  else { Add-Warn ".gitattributes: LFS rule for *.mp3 still present" }
} else {
  Add-Warn ".gitattributes not found (repo-wide EOL policy not enforced)"
}

# 4) core.autocrlf (advisory)
try {
  $autoCrlfLocal = (git config core.autocrlf 2>$null)
  $autoCrlfGlobal = (git config --global core.autocrlf 2>$null)
  if ($autoCrlfLocal -eq "false" -or [string]::IsNullOrEmpty($autoCrlfLocal)) {
    Add-Ok "core.autocrlf (local) is false or unset"
  } else {
    Add-Warn "core.autocrlf (local) = $autoCrlfLocal (recommend false)"
  }
  if ($autoCrlfGlobal -eq "false" -or [string]::IsNullOrEmpty($autoCrlfGlobal)) {
    Add-Ok "core.autocrlf (global) is false or unset"
  } else {
    Add-Warn "core.autocrlf (global) = $autoCrlfGlobal (recommend false)"
  }
}
catch {
  Add-Warn "Unable to read git config: $($_.Exception.Message)"
}

# 5) sync-docs callable?
if (Test-Path "tools/sync-docs.ps1") {
  Add-Ok "sync-docs.ps1 present (callable)"
} else {
  Add-Fail "sync-docs.ps1 missing"
}

# 6) checksum scripts present
if (Test-Path "tools/security/CHECKSUM_baseline.ps1" -and Test-Path "tools/security/CHECKSUM_verify.ps1") {
  Add-Ok "checksum scripts present"
} else {
  Add-Fail "checksum scripts missing"
}

# ---- Summary ----
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
if ($ok.Count)   { Write-Host ("OK   : " + ($ok -join "; "))   -ForegroundColor Green }
if ($warn.Count) { Write-Host ("WARN : " + ($warn -join "; ")) -ForegroundColor Yellow }
if ($fail.Count) { Write-Host ("FAIL : " + ($fail -join "; ")) -ForegroundColor Red }

if ($fail.Count -gt 0) { exit 1 } else { exit 0 }

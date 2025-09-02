# tools/verify-tools.ps1
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ok   = @()
$script:warn = @()
$script:fail = @()
$script:hadUnhandled = $false

function Add-Fail([string]$msg){ $script:fail += $msg; Write-Host "❌ $msg" -ForegroundColor Red }
function Add-Warn([string]$msg){ $script:warn += $msg; Write-Host "⚠  $msg" -ForegroundColor Yellow }
function Add-Ok  ([string]$msg){ $script:ok   += $msg; Write-Host "✅ $msg" -ForegroundColor Green }

# Turn ANY terminating error into a recorded failure, but keep going
trap {
  $script:hadUnhandled = $true
  Add-Fail ("Unhandled error: " + $_.Exception.Message)
  continue
}

# ---- Checks wrapped so we always hit the final summary ----
try {
  # Ensure in repo
  $repoRoot = git rev-parse --show-toplevel 2>$null
  if (-not $repoRoot) { Add-Fail "Not inside a git repository." }
  else { Set-Location $repoRoot }

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

  # 2) git-wip (tolerate policy)
  try {
    Unblock-File "tools/git-wip.ps1" -ErrorAction SilentlyContinue
    try { . "tools/git-wip.ps1" } catch {
      $src = Get-Content "tools/git-wip.ps1" -Raw -Encoding UTF8
      Invoke-Expression $src
    }
    if (Get-Command Pause-Work -ErrorAction SilentlyContinue) { Add-Ok "Function Pause-Work available" } else { Add-Fail "Function Pause-Work missing" }
    if (Get-Command Resume-Work -ErrorAction SilentlyContinue) { Add-Ok "Function Resume-Work available" } else { Add-Fail "Function Resume-Work missing" }
    if (Get-Alias pw -ErrorAction SilentlyContinue) { Add-Ok "Alias pw set" } else { Add-Warn "Alias pw not set (non-blocking)" }
    if (Get-Alias rw -ErrorAction SilentlyContinue) { Add-Ok "Alias rw set" } else { Add-Warn "Alias rw not set (non-blocking)" }
  }
  catch {
    Add-Fail "Failed to load tools/git-wip.ps1: $($_.Exception.Message)"
  }

  # 3) .gitattributes policies (ignore commented lines)
  $gaPath = ".gitattributes"
  if (Test-Path $gaPath) {
    $ga = Get-Content $gaPath -Raw
    if ($ga -match "(?im)^\*\s+text=auto\s+eol=lf") { Add-Ok ".gitattributes: * text=auto eol=lf found" } else { Add-Warn ".gitattributes: wildcard rule eol=lf not found" }
    if ($ga -match "(?im)^\*\.ps1\s+.*eol=lf") { Add-Ok ".gitattributes: *.ps1 eol=lf" } else { Add-Warn ".gitattributes: missing '*.ps1 eol=lf'" }
    # only flag if the mp3 LFS rule exists on a non-comment line
    if ($ga -match "(?im)^(?!\s*#).*?\*\.mp3\s+.*filter=lfs") {
      Add-Warn ".gitattributes: LFS rule for *.mp3 still present"
    } else {
      Add-Ok ".gitattributes: no LFS rule for *.mp3"
    }
  } else { Add-Warn ".gitattributes not found" }

  # 4) core.autocrlf advisory
  try {
    $autoCrlfLocal  = (git config core.autocrlf 2>$null)
    $autoCrlfGlobal = (git config --global core.autocrlf 2>$null)
    if ($autoCrlfLocal -eq "false" -or [string]::IsNullOrEmpty($autoCrlfLocal)) { Add-Ok "core.autocrlf (local) is false/unset" } else { Add-Warn "core.autocrlf (local) = $autoCrlfLocal (recommend false)" }
    if ($autoCrlfGlobal -eq "false" -or [string]::IsNullOrEmpty($autoCrlfGlobal)) { Add-Ok "core.autocrlf (global) is false/unset" } else { Add-Warn "core.autocrlf (global) = $autoCrlfGlobal (recommend false)" }
  } catch { Add-Warn "Unable to read git config: $($_.Exception.Message)" }

  # 5) presence of sync-docs
  if (Test-Path "tools/sync-docs.ps1") { Add-Ok "sync-docs.ps1 present" } else { Add-Fail "sync-docs.ps1 missing" }

  # 6) presence of checksum scripts
  if ( (Test-Path "tools/security/CHECKSUM_baseline.ps1") -and (Test-Path "tools/security/CHECKSUM_verify.ps1") ) {
    Add-Ok "checksum scripts present"
  } else { Add-Fail "checksum scripts missing" }

} finally {
  Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
  if ($script:ok.Count)   { Write-Host ("OK   : " + ($script:ok -join "; "))   -ForegroundColor Green }
  if ($script:warn.Count) { Write-Host ("WARN : " + ($script:warn -join "; ")) -ForegroundColor Yellow }
  if ($script:fail.Count) { Write-Host ("FAIL : " + ($script:fail -join "; ")) -ForegroundColor Red }

  if ( ($script:fail.Count -gt 0) -or $script:hadUnhandled ) { exit 1 } else { exit 0 }
}

# Quick WIP snapshot & resume
# Requires: git in PATH
# Provides: Pause-Work (pw), Resume-Work (rw)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Git {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git not found in PATH."
  }
  $top = git rev-parse --show-toplevel 2>$null
  if (-not $top) { throw "Not inside a git repository." }
  return $top.Trim()
}

function Get-DefaultRemote {
  $remote = (git remote 2>$null | Where-Object { $_ -eq 'origin' } | Select-Object -First 1)
  if (-not $remote) { $remote = (git remote 2>$null | Select-Object -First 1) }
  if (-not $remote) { throw "No git remote configured." }
  return $remote.Trim()
}

function New-WipBranchName {
  param([string]$Prefix = "wip")
  $stamp = Get-Date -Format "yyyyMMdd-HHmm"
  $name = "$Prefix/$stamp"
  $i = 0
  while ($true) {
    $existsLocal  = git rev-parse --verify --quiet "$name" 2>$null
    $existsRemote = git ls-remote --heads (Get-DefaultRemote) "$name" 2>$null
    if (-not $existsLocal -and -not $existsRemote) { return $name }
    $i++
    $name = "$Prefix/$stamp-{0:d2}" -f $i
  }
}

function Pause-Work {
  [CmdletBinding()]
  param([Alias('m')][string]$Message = "", [switch]$NoPush)
  try {
    $repo = Assert-Git
    Set-Location $repo
    git add -A | Out-Null
    $pending = git status --porcelain
    if ($pending) {
      $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss 'ICT'"
      $msg = "wip: auto-snapshot at $stamp"
      if ($Message) { $msg = "$msg — $Message" }
      git commit -m "$msg" | Out-Null
    } else {
      Write-Host "No changes; proceeding to branch creation." -ForegroundColor Yellow
    }
    $branch = New-WipBranchName
    git checkout -b $branch | Out-Null
    if (-not $NoPush) {
      $remote = Get-DefaultRemote
      git push -u $remote $branch
      Write-Host "✅ Snapshot saved & pushed → $branch" -ForegroundColor Green
    } else {
      Write-Host "✅ Snapshot saved locally → $branch" -ForegroundColor Green
    }
  } catch {
    Write-Host "❌ Pause-Work failed: $($_.Exception.Message)" -ForegroundColor Red
  }
}

function Resume-Work {
  try {
    $repo = Assert-Git
    Set-Location $repo
    $remote = Get-DefaultRemote
    git fetch --all --prune | Out-Null
    $last = git for-each-ref --sort=-committerdate --format="%(refname:short)" "refs/remotes/$remote/wip/" 2>$null | Select-Object -First 1
    if (-not $last) {
      Write-Host "No remote WIP branch found." -ForegroundColor Yellow
      return
    }
    $branchName = $last -replace "^$remote/",""
    git checkout $branchName | Out-Null
    git branch --set-upstream-to="$remote/$branchName" $branchName 2>$null | Out-Null
    Write-Host "✅ Checked out $branchName" -ForegroundColor Green
  } catch {
    Write-Host "❌ Resume-Work failed: $($_.Exception.Message)" -ForegroundColor Red
  }
}

try {
  if (-not (Get-Alias pw -ErrorAction SilentlyContinue)) { Set-Alias pw Pause-Work -Scope Global }
  if (-not (Get-Alias rw -ErrorAction SilentlyContinue)) { Set-Alias rw Resume-Work -Scope Global }
} catch {}

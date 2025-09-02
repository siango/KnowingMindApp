# Helper: Quick WIP snapshot & resume last WIP branch
# Requires: git in PATH, repo initialized, a remote exists (auto-detected)
# Encoding: UTF-8

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Git {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git not found in PATH. Install Git or open a shell where git is available."
  }
  $top = git rev-parse --show-toplevel 2>$null
  if (-not $top) { throw "Not inside a git repository." }
  return $top.Trim()
}

function Get-DefaultRemote {
  # Prefer 'origin', else pick the first configured remote
  $remote = (git remote 2>$null | Where-Object { $_ -eq 'origin' } | Select-Object -First 1)
  if (-not $remote) {
    $remote = (git remote 2>$null | Select-Object -First 1)
  }
  if (-not $remote) { throw "No git remote configured. Run: git remote add origin <url>" }
  return $remote.Trim()
}

function New-WipBranchName {
  param(
    [string]$Prefix = "wip",
    [string]$BaseStamp = $(Get-Date -Format "yyyyMMdd-HHmm")
  )
  $name = "$Prefix/$BaseStamp"
  # Avoid collisions by adding -01, -02, ...
  $suffix = 0
  while ($true) {
    $existsLocal  = git rev-parse --verify --quiet "$name"           2>$null
    $existsRemote = git ls-remote --heads (Get-DefaultRemote) "$name" 2>$null
    if (-not $existsLocal -and -not $existsRemote) { return $name }
    $suffix++
    $name = "$Prefix/$BaseStamp-{0:d2}" -f $suffix
  }
}

function Pause-Work {
  <#
    .SYNOPSIS
      Create a WIP branch, commit pending changes (if any), and push.

    .PARAMETER Message
      Optional message to append in the snapshot commit.

    .PARAMETER NoPush
      Do not push to remote (local snapshot only).
  #>
  [CmdletBinding()]
  param(
    [Alias('m')][string]$Message = "",
    [switch]$NoPush
  )
  try {
    $repo = Assert-Git
    Set-Location $repo

    # Stage all files
    git add -A | Out-Null

    # Commit only if there are pending changes
    $pending = git status --porcelain
    if ($pending) {
      $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss 'ICT'"
      $msg   = "wip: auto-snapshot at $stamp"
      if ($Message) { $msg = "$msg — $Message" }
      git commit -m "$msg" | Out-Null
    } else {
      Write-Host "No changes to commit; proceeding to branch creation." -ForegroundColor Yellow
    }

    # Create a new unique WIP branch
    $branch = New-WipBranchName

    git checkout -b $branch | Out-Null

    if (-not $NoPush) {
      $remote = Get-DefaultRemote
      git push -u $remote $branch
      Write-Host "✅ Snapshot saved & pushed → $branch" -ForegroundColor Green
    } else {
      Write-Host "✅ Snapshot saved locally → $branch (not pushed)" -ForegroundColor Green
    }
  }
  catch {
    Write-Host "❌ Pause-Work failed: $($_.Exception.Message)" -ForegroundColor Red
    throw
  }
}

function Resume-Work {
  <#
    .SYNOPSIS
      Check out the most recent remote WIP branch (wip/*).
  #>
  [CmdletBinding()]
  param()
  try {
    $repo = Assert-Git
    Set-Location $repo

    $remote = Get-DefaultRemote
    git fetch --all --prune | Out-Null

    # Pick latest by committerdate among remote refs wip/*
    $last = git for-each-ref --sort=-committerdate --format="%(refname:short)" "refs/remotes/$remote/wip/" 2>$null | Select-Object -First 1
    if (-not $last) {
      Write-Host "No remote WIP branch found under $remote/wip/*" -ForegroundColor Yellow
      return
    }
    $branchName = $last -replace "^$remote/",""
    git checkout $branchName | Out-Null
    git branch --set-upstream-to="$remote/$branchName" $branchName 2>$null | Out-Null
    Write-Host "✅ Checked out $branchName" -ForegroundColor Green
  }
  catch {
    Write-Host "❌ Resume-Work failed: $($_.Exception.Message)" -ForegroundColor Red
    throw
  }
}

# Optional: define handy global aliases if not already defined
try {
  if (-not (Get-Alias pw -ErrorAction SilentlyContinue)) { Set-Alias pw Pause-Work -Scope Global }
  if (-not (Get-Alias rw -ErrorAction SilentlyContinue)) { Set-Alias rw Resume-Work -Scope Global }
} catch {}

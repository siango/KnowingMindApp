
<# 
  check-all.ps1 — Windows readiness & project health (KnowingMindSuite)
  Usage: .\check-all.ps1 [-Quick]
  Exit code: 0 when no hard failures, 1 otherwise.
#>

param(
  [switch]$Quick
)

$Host.UI.RawUI.WindowTitle = "KnowingMindSuite • Windows Check"
$ErrorActionPreference = "Stop"
function Ok([string]$m){ Write-Host "✓ $m" -ForegroundColor Green }
function Warn([string]$m){ Write-Host "! $m" -ForegroundColor Yellow }
function Err([string]$m){ Write-Host "✗ $m" -ForegroundColor Red }

$log = "check-all-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss")
Start-Transcript -Path $log | Out-Null

Write-Host "== KnowingMindSuite • Windows Check $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')" -ForegroundColor Cyan
Write-Host "User: $env:USERNAME  Machine: $env:COMPUTERNAME" -ForegroundColor DarkGray

# --- 1) Toolchain presence ---
$need = @("git","node","python","ffmpeg","curl")
foreach($c in $need){
  $p = (Get-Command $c -ErrorAction SilentlyContinue)
  if($p){ 
    try {
      $v = & $p.Source --version 2>$null | Select-Object -First 1
    } catch { $v = "" }
    Ok "$c present $v"
  } else {
    Warn "$c missing — install recommended"
  }
}
# optional
foreach($c in @("gh","gcloud","rclone")){
  $p = (Get-Command $c -ErrorAction SilentlyContinue)
  if($p){ Ok "$c present" } else { Warn "$c not found (optional)" }
}

# --- 2) Git repo status ---
try{
  $inside = (git rev-parse --is-inside-work-tree) 2>$null
} catch { $inside = "" }
if($inside -eq "true"){
  $root = git rev-parse --show-toplevel
  Write-Host "Repo root: $root"
  $branch = git rev-parse --abbrev-ref HEAD
  Ok "On branch: $branch"
  Write-Host "Remotes:"; git remote -v
  Write-Host "Recent commits:"; git --no-pager log --oneline -n 5
  $remote = (git remote get-url origin)
  if($remote -like "https://github.com/*"){
    Ok "Origin via HTTPS (Windows credential manager supported)"
  } else {
    Ok "Origin via SSH"
  }
} else {
  Err "Not inside a Git repository"
  $crit += 1
}

# --- 3) pw / rw availability ---
$crit = 0
$pathPw = (Get-Command pw -ErrorAction SilentlyContinue)
$pathRw = (Get-Command rw -ErrorAction SilentlyContinue)
if($pathPw){ Ok "pw available: $($pathPw.Source)" } else { Warn "pw not found in PATH" }
if($pathRw){ Ok "rw available: $($pathRw.Source)" } else { Warn "rw not found in PATH" }

# --- 4) gcloud config & Cloud Run ---
$gcloud = Get-Command gcloud -ErrorAction SilentlyContinue
if($gcloud){
  $proj = (gcloud config get-value core/project) 2>$null
  $region = (gcloud config get-value run/region) 2>$null
  Write-Host "gcloud project: $proj | region: $region"
  if(-not $proj){ Warn "gcloud not configured — run: gcloud init" }
  if($region){
    Write-Host "Cloud Run services (region=$region):"
    try{
      gcloud run services list --platform=managed --region=$region --format="table(NAME,URL,INGRESS,GENERATION)"
    } catch {
      Warn "Unable to list Cloud Run services"
    }
  }
} else {
  Warn "gcloud not installed — skip GCP checks"
}

# --- 5) Health checks (optional URLs via env vars) ---
$services = @("ARUNROO_URL","SATISHIFT_URL","KMA_API_URL","N8N_BASE_URL")
foreach($s in $services){
  $u = [Environment]::GetEnvironmentVariable($s,"Process")
  if([string]::IsNullOrWhiteSpace($u)){ $u = [Environment]::GetEnvironmentVariable($s,"User") }
  if([string]::IsNullOrWhiteSpace($u)){ $u = [Environment]::GetEnvironmentVariable($s,"Machine") }
  if($u){
    $url = if($s -eq "N8N_BASE_URL") { $u } else { "$u/api/ping" }
    try{
      $res = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10
      if($res.StatusCode -ge 200 -and $res.StatusCode -lt 400){
        Ok "$s healthy ($url)"
      } else {
        Warn "$s responded $($res.StatusCode)"
      }
    } catch {
      Warn "$s ping failed: $($_.Exception.Message)"
    }
  }
}

# --- 6) rclone (Drive) ---
$rclone = Get-Command rclone -ErrorAction SilentlyContinue
if($rclone){
  try{
    $remotes = rclone listremotes
    if($remotes){
      $first = ($remotes | Select-Object -First 1).TrimEnd(":")
      Write-Host "rclone remote detected: $first"
      try{
        rclone ls "$first:/" --max-depth 1 | Out-Null
        Ok "rclone remote accessible"
      } catch { Warn "rclone remote not accessible" }
    } else {
      Warn "rclone has no remotes configured"
    }
  } catch { Warn "rclone check failed" }
} else {
  Warn "rclone not installed — skip Drive checks"
}

Stop-Transcript | Out-Null
Write-Host ""
if($crit -gt 0){
  Err "Completed with $crit critical issue(s). See $log"
  exit 1
} else {
  Ok "All checks completed (no critical failure). Log: $log"
  exit 0
}

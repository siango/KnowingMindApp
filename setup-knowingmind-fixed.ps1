<#
Setup KnowingMindSuite (Windows Server 2019)
- ตั้งเครื่องใหม่ให้พร้อมใช้งาน
- ติดตั้งเครื่องมือหลัก (git, gh, node, python, 7zip, gcloud*)
- ตั้งค่า Git
- โคลน/อัปเดตรีโป
- เพิ่มฟังก์ชันถาวร: kmcd, km-health, pw, rw, sync
- ใช้ได้ซ้ำ ปลอดภัย (idempotent)
#>

param(
  [string]$RepoUrl = "https://github.com/siango/KnowingMindApp.git",
  [string]$RepoDir = "$env:USERPROFILE\AndroidProjects\KnowingMindSuite",
  [string]$GitUser = "Kanthon Chaiphan",
  [string]$GitEmail = "YOUR_GITHUB_NOREPLY_EMAIL"
)

# ---------------- Helpers ----------------
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "✔ $m" -ForegroundColor Green }
function Warn($m){ Write-Host "⚠ $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "✘ $m" -ForegroundColor Red; exit 1 }

function Ensure-Choco {
  if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Info "Installing Chocolatey"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  }
  Ok "Chocolatey ready"
}

function Install-ChocoPkg([string]$name) {
  try {
    # ติดตั้งถ้ายังไม่มี (หรืออัปเดตเวอร์ชัน)
    choco install $name -y --no-progress | Out-Null
  } catch {
    Warn "choco install $name failed: $($_.Exception.Message)"
  }
}

function Refresh-Env {
  try {
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue
    if (Get-Command refreshenv -ErrorAction SilentlyContinue) { refreshenv }
  } catch { }
}

# ---------------- ExecutionPolicy ----------------
Info "Set ExecutionPolicy (CurrentUser=RemoteSigned)"
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# ---------------- Chocolatey & Packages ----------------
Ensure-Choco
Info "Installing base packages via Chocolatey"
$pkgs = @("git","gh","nodejs-lts","python3","7zip")
$pkgs | ForEach-Object { Install-ChocoPkg $_ }

# Google Cloud SDK: ติดตั้งเฉพาะถ้ายังไม่มี
if (Get-Command gcloud -ErrorAction SilentlyContinue) {
  Ok "Found gcloud — skip Chocolatey install"
} else {
  Info "Trying to install googlecloudsdk via Chocolatey"
  Install-ChocoPkg "googlecloudsdk"
  if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Warn "gcloud still not found after choco. You can install later with Google official installer."
  }
}

# refresh PATH/ENV หลังติดตั้ง
Refresh-Env

# ---------------- Git Config ----------------
Info "Configure Git"
git config --global core.autocrlf false
git config --global core.eol lf
git config --global pull.ff only
git config --global init.defaultbranch main
if (-not (git config --global user.name))  { git config --global user.name  $GitUser }
if (-not (git config --global user.email)) { git config --global user.email $GitEmail }
git config --global credential.helper manager-core
Ok "Git configured"

# ---------------- Clone / Update Repo ----------------
Info "Prepare repo at: $RepoDir"
$parent = Split-Path -Parent $RepoDir
if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

if (-not (Test-Path (Join-Path $RepoDir ".git"))) {
  Info "Cloning repository..."
  try {
    if ($env:GITHUB_TOKEN) {
      git -c http.extraheader="Authorization: Bearer $env:GITHUB_TOKEN" clone $RepoUrl $RepoDir
    } else {
      git clone $RepoUrl $RepoDir
    }
  } catch { Err "Clone failed: $($_.Exception.Message)" }
} else {
  Info "Updating existing repository..."
  Push-Location $RepoDir
  git fetch --all --prune
  git pull
  Pop-Location
}
Ok "Repo ready at $RepoDir"

# ---------------- Profile Functions (persist) ----------------
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath -Force | Out-Null }

$profileBlock = @'
function Use-Python {
  if (Get-Command python -ErrorAction SilentlyContinue) { return "python" }
  elseif (Get-Command py -ErrorAction SilentlyContinue) { return "py -3" }
  else { throw "Python not found. Reopen PowerShell after installation." }
}

function kmcd {
  Set-Location -LiteralPath (Join-Path $env:USERPROFILE "AndroidProjects\KnowingMindSuite")
}

function pw {
  param([string]$msg="snapshot")
  $ts = Get-Date -Format "yyyyMMdd-HHmm"
  git add -A
  git commit -m $msg -ErrorAction SilentlyContinue
  git branch -D "wip/$ts" -ErrorAction SilentlyContinue
  git checkout -b "wip/$ts"
  git push origin "wip/$ts"
  Write-Host "✔ Snapshot saved to wip/$ts"
}

function rw {
  git fetch --all --prune
  $list = (git ls-remote --heads origin "wip/*") -split [Environment]::NewLine | Where-Object { $_ -ne "" } `
    | ForEach-Object { ($_ -split "\s+")[1] } `
    | ForEach-Object { $_.Substring($_.LastIndexOf('/')+1) } `
    | Sort-Object -Descending
  if ($list -and $list[0]) {
    $b = $list[0]
    git checkout $b
    git pull
    Write-Host "✔ Switched to $b"
  } else {
    Write-Host "No remote wip branch found"
  }
}

function sync {
  git fetch --all --prune
  git pull
  if (Get-Command gcloud -ErrorAction SilentlyContinue) {
    try { gcloud components update --quiet } catch { Write-Host "gcloud update skipped" -ForegroundColor Yellow }
  }
  try {
    $py = Use-Python
    & $py -m pip install --upgrade pip
  } catch { Write-Host "Python not available yet" -ForegroundColor Yellow }
  if (Test-Path package-lock.json) { npm ci } elseif (Test-Path package.json) { npm install }
  Write-Host "✔ Sync completed"
}

function km-health {
  Write-Host "== Versions ==" -ForegroundColor Cyan
  git --version
  node -v
  try { & (Use-Python) --version } catch { Write-Warning $_ }
  if (Get-Command gcloud -ErrorAction SilentlyContinue) { gcloud version | Select-String "Google Cloud SDK" }
  Write-Host "== Git Status ==" -ForegroundColor Cyan
  if (Test-Path .git) {
    git status -sb
    Write-Host "== Remotes ==" -ForegroundColor Cyan
    git remote -v
  } else {
    Write-Host "(run inside repo folder)"
  }
}
'@

# เขียนครั้งเดียว ถ้ายังไม่มีฟังก์ชันอยู่ในโปรไฟล์
if (-not (Get-Content $profilePath | Select-String -SimpleMatch "function km-health")) {
  Add-Content -Path $profilePath -Value "`r`n# == KnowingMindSuite helpers ==" 
  Add-Content -Path $profilePath -Value $profileBlock
  Ok "Added kmcd/km-health/pw/rw/sync to $profilePath"
}

# ---------------- Python alias (ชั่วคราวในเซสชันนี้) ----------------
if (-not (Get-Command python -ErrorAction SilentlyContinue) -and (Get-Command py -ErrorAction SilentlyContinue)) {
  Set-Alias -Name python -Value py -Scope Global
}

# ---------------- Final check ----------------
Refresh-Env
if (Test-Path $profilePath) { . $profilePath }

Set-Location -LiteralPath $RepoDir
km-health

Ok "All done. Open a NEW PowerShell window next time for auto-loaded commands (kmcd, km-health, pw, rw, sync)."

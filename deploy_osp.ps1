Param(
  [string]$Owner  = "siango",
  [string]$Repo   = "KnowingMindDashboard",
  [string]$Branch = "gh-pages",
  [string]$Domain = "knowingmindproject.website"
)
$ErrorActionPreference = 'Stop'
function Info($m){ Write-Host "[i] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[✓] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[!] $m" -ForegroundColor Yellow }
function Die($m){ Write-Host "[x] $m" -ForegroundColor Red; exit 1 }
if(-not (Get-Command git -ErrorAction SilentlyContinue)){ Die "ต้องติดตั้ง: git" }
$work = Join-Path $env:TEMP ("kms_dash_" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $work | Out-Null
$remote = if($env:GITHUB_TOKEN){ "https://$($env:GITHUB_TOKEN)@github.com/$Owner/$Repo.git" } else { "https://github.com/$Owner/$Repo.git" }
git clone --depth 1 $remote $work | Out-Null
Push-Location $work
try { git checkout $Branch 2>$null } catch { git checkout -b $Branch }
Get-ChildItem -Force | Where-Object { $_.Name -notin @(".git") } | Remove-Item -Recurse -Force
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Copy-Item -Recurse -Force (Join-Path $here "site\*") .
Set-Content -Path "CNAME" -Value $Domain -NoNewline
git add -A
$stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "[OSP] Deploy quickstart dashboard @ $stamp" | Out-Null
git push origin $Branch
Ok "Published to $Owner/$Repo:$Branch → https://$Domain/"
Pop-Location

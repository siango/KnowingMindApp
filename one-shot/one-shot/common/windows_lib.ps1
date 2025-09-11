# one-shot/common/windows_lib.ps1 — helpers (Windows)
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[i] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[✓] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[!] $m" -ForegroundColor Yellow }
function Die($m){ Write-Host "[x] $m" -ForegroundColor Red; exit 1 }

function Ensure-Tools{
  $need = @("git","curl.exe")
  foreach($n in $need){
    if(-not (Get-Command $n -ErrorAction SilentlyContinue)){
      Die "ต้องติดตั้ง: $n"
    }
  }
}

function Import-Yaml($Path){
  try {
    if(Get-Module -ListAvailable -Name powershell-yaml){
      Import-Module powershell-yaml -ErrorAction Stop
      return (Get-Content $Path -Raw | ConvertFrom-Yaml)
    }
  } catch {}
  # fallback (very naive key: value loader, supports basic nesting only for known keys)
  $obj = @{}; $cur = $null
  Get-Content $Path | ForEach-Object {
    if($_ -match '^\s*([A-Za-z0-9_-]+):\s*(.*)$'){
      $k=$matches[1]; $v=$matches[2].Trim()
      if($v -eq ""){ $obj[$k]=@{}; $cur=$k }
      else { $obj[$k] = $v }
    } elseif($_ -match '^\s{2,}([A-Za-z0-9_-]+):\s*(.*)$' -and $cur){
      $k=$matches[1]; $v=$matches[2].Trim()
      $obj[$cur][$k]=$v
    }
  }
  return $obj
}

function Git-Sync($Url,$Path,$Branch){
  if(-not (Test-Path $Path)){
    git clone --depth 1 -b $Branch $Url $Path | Out-Null
  } else {
    Push-Location $Path
    git fetch --depth 1 origin $Branch | Out-Null
    git checkout $Branch | Out-Null
    git pull --ff-only | Out-Null
    Pop-Location
  }
}

function Write-Matrix($Device,$Status,$Note){
  $file = Join-Path (Split-Path $PSScriptRoot -Parent) "checks\\health_matrix.md"
  if(-not (Test-Path $file)){
    "| Device | Status | Note |`n|---|---|---|`n" | Out-File -FilePath $file -Encoding utf8
  }
  "| $Device | $Status | $Note |" | Out-File -FilePath $file -Append -Encoding utf8
}
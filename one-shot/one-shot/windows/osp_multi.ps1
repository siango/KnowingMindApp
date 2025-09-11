Param(
  [switch]$All,
  [string]$Only
)
$ErrorActionPreference = 'Stop'

if(-not $All -and [string]::IsNullOrWhiteSpace($Only)){
  Write-Host "ใช้: .\osp_multi.ps1 -All | -Only <device_id>"
  exit 2
}

$devdir = Join-Path $PSScriptRoot "..\devices"
$single = Join-Path $PSScriptRoot "osp_single.ps1"

function Run-One($d){
  & $single -Device $d
}

if($All){
  Get-ChildItem $devdir -Filter *.yaml | ForEach-Object {
    $dev = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    Run-One $dev
  }
} else {
  Run-One $Only
}
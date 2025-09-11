Param(
  [switch]$All,
  [string]$Only
)
$ROOT = Split-Path $MyInvocation.MyCommand.Path -Parent
. (Join-Path $ROOT "..\common\windows_lib.ps1")

$DeviceDir = Join-Path $ROOT "..\devices"
$files = Get-ChildItem $DeviceDir -Filter *.yaml

foreach($f in $files){
  $id = [System.IO.Path]::GetFileNameWithoutExtension($f)
  if($All -or ($Only -eq $id)){
    Write-Host "==> Running for $id"
    # TODO: parse yaml and call Git-Sync, Health-Check etc.
  }
}

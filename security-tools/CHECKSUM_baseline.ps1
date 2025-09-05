[CmdletBinding()]
param(
  [Parameter(Position=0)][string]$Root=".",
  [Parameter(Position=1)][string]$OutFile="CHECKSUMS_SHA256.txt"
)
Write-Host "== Create SHA256 baseline for $Root"
$files = Get-ChildItem -Path $Root -Recurse -File | Sort-Object FullName
$lines = foreach($f in $files){
  $h = Get-FileHash -Path $f.FullName -Algorithm SHA256
  "{0}  {1}" -f $h.Hash, (Resolve-Path -LiteralPath $f.FullName -Relative)
}
$lines | Set-Content -Encoding UTF8 $OutFile
Write-Host "Wrote $OutFile"

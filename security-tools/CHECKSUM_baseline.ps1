# Creates baseline SHA256 checksums for all files under ./project-docs
param(
  [string]$TargetPath = ".\project-docs",
  [string]$OutputFile = ".\checksums.txt"
)

if(!(Test-Path $TargetPath)){ Write-Error "TargetPath not found: $TargetPath"; exit 1 }

Get-ChildItem -Recurse $TargetPath -File | ForEach-Object {
  $hash = Get-FileHash -Algorithm SHA256 -Path $_.FullName
  "{0}  {1}" -f $hash.Hash, $hash.Path
} | Set-Content -Encoding UTF8 $OutputFile

Write-Host "Baseline written to $OutputFile" -ForegroundColor Green

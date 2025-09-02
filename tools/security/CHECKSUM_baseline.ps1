param([Parameter(Mandatory=$true)][string]$TargetPath)

$hashes = Get-ChildItem -Recurse $TargetPath | Get-FileHash -Algorithm SHA256 |
  ForEach-Object { "$($_.Hash)  $($_.FullName)" }

$baselinePath = Join-Path $TargetPath 'checksums.txt'
$hashes | Set-Content -Path $baselinePath -Encoding UTF8
Write-Host "Baseline written to $baselinePath"

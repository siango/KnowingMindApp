param([Parameter(Mandatory=$true)][string]$TargetPath)

$baselinePath = Join-Path $TargetPath 'checksums.txt'
if (-not (Test-Path $baselinePath)) { throw "No checksums.txt found in $TargetPath" }

$cur = Get-ChildItem -Recurse $TargetPath | Get-FileHash -Algorithm SHA256 |
  ForEach-Object { "$($_.Hash)  $($_.FullName)" }
$base = Get-Content $baselinePath

Compare-Object -ReferenceObject $base -DifferenceObject $cur

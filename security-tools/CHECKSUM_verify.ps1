# Verifies current SHA256 checksums against baseline
param(
  [string]$TargetPath = ".\project-docs",
  [string]$BaselineFile = ".\checksums.txt"
)

if(!(Test-Path $TargetPath)){ Write-Error "TargetPath not found: $TargetPath"; exit 1 }
if(!(Test-Path $BaselineFile)){ Write-Error "Baseline file not found: $BaselineFile"; exit 1 }

# Build current list
$current = Get-ChildItem -Recurse $TargetPath -File | ForEach-Object {
  $hash = Get-FileHash -Algorithm SHA256 -Path $_.FullName
  "{0}  {1}" -f $hash.Hash, $hash.Path
}

$baseline = Get-Content $BaselineFile

$diff = Compare-Object -ReferenceObject $baseline -DifferenceObject $current
if($diff){
  Write-Warning "Differences detected!"
  $diff | ForEach-Object { $_ | Out-String | Write-Host -ForegroundColor Yellow }
  exit 2
}else{
  Write-Host "No differences. All good." -ForegroundColor Green
}

[CmdletBinding()]
param(
  [Parameter(Position=0)][string]$Root=".",
  [Parameter(Position=1)][string]$ChecksumFile="CHECKSUMS_SHA256.txt"
)
if(!(Test-Path $ChecksumFile)){ Write-Error "Checksum file not found: $ChecksumFile"; exit 2 }
$fail=0
Get-Content $ChecksumFile | ForEach-Object {
  if($_ -match "^(?<hash>[0-9A-Fa-f]{64})\s{2}(?<path>.+)$"){
    $hash=$matches.hash
    $path=Join-Path $Root $matches.path
    if(Test-Path $path){
      $h2=(Get-FileHash -Path $path -Algorithm SHA256).Hash
      if($h2 -ne $hash){ Write-Host "[DIFF] $path"; $fail++ }
    } else {
      Write-Host "[MISSING] $path"; $fail++
    }
  }
}
if($fail -gt 0){ Write-Error "Verification failed: $fail issue(s)"; exit 1 }
Write-Host "All good."

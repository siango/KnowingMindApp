[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$JobName,
  [string]$Region = "asia-southeast1",
  [string]$TimeZone = "Asia/Bangkok"
)
$ErrorActionPreference = "Stop"
# ต้องมี gcloud และ auth แล้ว
gcloud scheduler jobs update http $JobName --location $Region --time-zone $TimeZone
Write-Host "Updated $JobName timezone to $TimeZone in $Region" -ForegroundColor Green

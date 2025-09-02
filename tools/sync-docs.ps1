# Sync docs, log entry, create zips, update checksums, timezone script

param(
  [Parameter(Mandatory=$true)][string]$ProjectDocs,
  [string]$Entry
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ProjectDocsPath = Resolve-Path $ProjectDocs
$null = New-Item -ItemType Directory -Force -Path $ProjectDocsPath

if ([string]::IsNullOrWhiteSpace($Entry)) {
  $Entry = 'Reminder: (โปรดระบุข้อความเตือน)'
}

$now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$logPath = Join-Path $ProjectDocsPath 'log.md'

$md = @"
## [$now] [reminder]
- $Entry

"@
Add-Content -Path $logPath -Value $md -Encoding UTF8
Write-Host "Appended reminder to $logPath" -ForegroundColor Green

# checksum
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$checksumScript = Join-Path $root 'security\CHECKSUM_baseline.ps1'
if (Test-Path $checksumScript) {
  & $checksumScript -TargetPath $ProjectDocsPath | Out-Null
  Write-Host "Checksum baseline updated for $ProjectDocsPath" -ForegroundColor DarkCyan
}

# out dir
$outDir = Join-Path $root '..\out' | Resolve-Path -ErrorAction SilentlyContinue
if (-not $outDir) { $outDir = Join-Path (Split-Path $root -Parent) 'out'; New-Item -ItemType Directory -Force -Path $outDir | Out-Null }

# zip project-docs
$zip1 = Join-Path $outDir 'project-docs.zip'
if (Test-Path $zip1) { Remove-Item $zip1 -Force }
Compress-Archive -Path (Join-Path $ProjectDocsPath '*') -DestinationPath $zip1
Write-Host "ZIP #1 written: $zip1" -ForegroundColor Green

# zip security-tools
$secDir = Join-Path $root 'security'
$zip2 = Join-Path $outDir 'security-tools.zip'
if (Test-Path $secDir) {
  if (Test-Path $zip2) { Remove-Item $zip2 -Force }
  Compress-Archive -Path (Join-Path $secDir '*') -DestinationPath $zip2
  Write-Host "ZIP #2 written: $zip2" -ForegroundColor Green
}

# timezone script
$scriptsDir = Join-Path $root '..\scripts'
$null = New-Item -ItemType Directory -Force -Path $scriptsDir
$tzScript = Join-Path $scriptsDir 'set-scheduler-timezone.ps1'
@'
param(
  [Parameter(Mandatory=$true)][string]$JobName,
  [Parameter(Mandatory=$true)][string]$Region,
  [Parameter(Mandatory=$true)][string]$TimeZone
)
$cmd = "gcloud scheduler jobs update http $JobName --location $Region --time-zone=$TimeZone"
Write-Host "Updated $JobName timezone to $TimeZone in $Region"
Invoke-Expression $cmd
'@ | Set-Content -Path $tzScript -Encoding UTF8
Write-Host "Timezone script created: $tzScript" -ForegroundColor Green

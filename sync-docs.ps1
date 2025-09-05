# ---------- REPLACE sync-docs.ps1 COMPLETELY WITH THIS ----------
#Requires -Version 5.1
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectDocs,

  [Parameter()]
  [string]$Entry
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# ให้คอนโซลพิมพ์/อ่าน UTF-8
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# Path พื้นฐาน
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDocsPath = Resolve-Path $ProjectDocs
$null = New-Item -ItemType Directory -Force -Path $ProjectDocsPath

# ถ้าไม่ได้ส่ง Entry มา ใส่ค่าเริ่มต้น (ภาษาไทย)
if ([string]::IsNullOrWhiteSpace($Entry)) {
  $Entry = 'Reminder: (โปรดระบุข้อความเตือน)'
}

$now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$logPath = Join-Path $ProjectDocsPath 'log.md'

# เขียน markdown แบบ here-string (ขึ้นบรรทัดใหม่ให้ครบ)
$md = @"
## [$now] [reminder]
- $Entry

"@

Add-Content -Path $logPath -Value $md -Encoding UTF8
Write-Host "Appended reminder to $logPath" -ForegroundColor Green

# ถ้ามีสคริปต์ checksum ให้รัน (ไม่บังคับ)
$checksumScript = Join-Path $Root 'security-tools\CHECKSUM_baseline.ps1'
if (Test-Path $checksumScript) {
  & $checksumScript -TargetPath $ProjectDocsPath | Out-Null
  Write-Host "Checksum baseline updated for $ProjectDocsPath" -ForegroundColor DarkCyan
}

# เตรียมโฟลเดอร์ out
$outDir = Join-Path $Root 'out'
$null = New-Item -ItemType Directory -Force -Path $outDir

# ZIP #1: project-docs
$zip1 = Join-Path $outDir 'project-docs.zip'
if (Test-Path $zip1) { Remove-Item $zip1 -Force }
Compress-Archive -Path (Join-Path $ProjectDocsPath '*') -DestinationPath $zip1
Write-Host "ZIP #1 written: $zip1" -ForegroundColor Green

# ZIP #2: security-tools (ถ้ามี)
$secDir = Join-Path $Root 'security-tools'
$zip2 = Join-Path $outDir 'security-tools.zip'
if (Test-Path $secDir) {
  if (Test-Path $zip2) { Remove-Item $zip2 -Force }
  Compress-Archive -Path (Join-Path $secDir '*') -DestinationPath $zip2
  Write-Host "ZIP #2 written: $zip2" -ForegroundColor Green
} else {
  Write-Host "security-tools folder not found; skip ZIP #2" -ForegroundColor Yellow
}

# วางสคริปต์ timezone สำหรับ Cloud Scheduler
$scriptsDir = Join-Path $Root 'scripts'
$null = New-Item -ItemType Directory -Force -Path $scriptsDir
$tzScript = Join-Path $scriptsDir 'set-scheduler-timezone.ps1'
@'
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
'@ | Set-Content -Path $tzScript -Encoding UTF8
Write-Host "Timezone script created: $tzScript" -ForegroundColor DarkGreen
# ---------- END ----------

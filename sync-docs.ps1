param(
  [string]$ProjectDocs = ".\project-docs",
  [string]$LogFile = "PROJECT_LOG.md",
  [string]$Entry = ""
)

$target = Join-Path $ProjectDocs $LogFile
if(!(Test-Path $target)){ Write-Error "Log file not found: $target"; exit 1 }

$now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss (Asia/Bangkok)")
if([string]::IsNullOrWhiteSpace($Entry)){ $Entry = "Reminder: (โปรดระบุข้อความเตือน)"; }

$md = @"
## [$now] [reminder]
- $Entry
"@

Add-Content -Path $target -Value $md -Encoding UTF8
Write-Host "Appended reminder to $target" -ForegroundColor Green

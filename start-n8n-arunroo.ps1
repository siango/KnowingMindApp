<#
.SYNOPSIS
  Start n8n locally with recommended env for ArunRoo.
.DESCRIPTION
  Sets environment variables for one session and runs n8n.
  Press Ctrl+C to stop. Re-run this script to start again.
.PARAMETER Port
  Port for n8n UI (default 5678)
.PARAMETER Timezone
  IANA timezone (default Asia/Bangkok)
#>
param(
  [int]$Port = 5678,
  [string]$Timezone = "Asia/Bangkok"
)

# ---- Required envs for n8n ----
$env:N8N_PORT = "$Port"
$env:GENERIC_TIMEZONE = $Timezone

# ---- (Optional) Your project envs used by the workflow ----
# Set these before first run or edit and rerun this script.
# Facebook / Instagram
$env:FB_PAGE_ID            = $env:FB_PAGE_ID            # e.g. "1234567890"
$env:FB_PAGE_TOKEN         = $env:FB_PAGE_TOKEN         # e.g. "EAAB..."
$env:IG_BUSINESS_ID        = $env:IG_BUSINESS_ID        # e.g. "1784..."
$env:IG_TOKEN              = $env:IG_TOKEN              # e.g. "IGQVJ..."
# Content
$env:ARUNROO_IMG_CDN_BASE  = $env:ARUNROO_IMG_CDN_BASE  # e.g. "https://cdn.example.com/arunroo"
$env:DAILY_CAPTION_TEMPLATE= $env:DAILY_CAPTION_TEMPLATE# e.g. "#อรุณรู้ #KnowingMind"

Write-Host "Starting n8n on http://localhost:$Port  (timezone=$Timezone)"
Write-Host "กด Ctrl+C เพื่อหยุดการทำงาน"

# Prefer local install if available, fallback to npx
$n8nCmd = Get-Command n8n -ErrorAction SilentlyContinue
if ($n8nCmd) {
  n8n
} else {
  npx n8n
}
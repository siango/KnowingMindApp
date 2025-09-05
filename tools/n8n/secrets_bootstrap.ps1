Param([string]$EnvFile = "tools\n8n\.env")

$N8N_BASE_URL = Read-Host "N8N_BASE_URL (e.g. https://siango.app.n8n.cloud - no trailing slash)"
$N8N_BASE_URL = $N8N_BASE_URL.TrimEnd("/")
$N8N_API_KEY = Read-Host "N8N_API_KEY (paste your n8n API key)"
$N8N_BASIC_AUTH_USER = Read-Host "N8N_BASIC_AUTH_USER (optional)"
$N8N_BASIC_AUTH_PASSWORD = Read-Host "N8N_BASIC_AUTH_PASSWORD (optional)"

$lines = @(
  "N8N_BASE_URL=$N8N_BASE_URL"
  "N8N_API_KEY=$N8N_API_KEY"
  "N8N_BASIC_AUTH_USER=$N8N_BASIC_AUTH_USER"
  "N8N_BASIC_AUTH_PASSWORD=$N8N_BASIC_AUTH_PASSWORD"
)
$dir = Split-Path -Parent $EnvFile
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
Set-Content -Path $EnvFile -Encoding UTF8 -Value ($lines -join [Environment]::NewLine)
Write-Host "Wrote $EnvFile"

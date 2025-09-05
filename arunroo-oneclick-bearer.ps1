<# arunroo-oneclick-bearer.ps1
- Ping n8n
- Auth via API Key or Basic
- List & activate workflows by name pattern
- Plain ASCII to avoid encoding issues
#>

[CmdletBinding()]
param(
  [Parameter(Position=0)]
  [string]$BaseUrl = $env:N8N_BASE_URL,
  [string]$ApiKey = $env:N8N_API_KEY,
  [string]$BasicUser = $env:N8N_BASIC_AUTH_USER,
  [string]$BasicPass = $env:N8N_BASIC_AUTH_PASSWORD,

  # Workflow name (or part of it) to match
  [string]$Match = "ArunRoo - Podcast Queue",

  # Only list matched workflows; do not activate
  [switch]$ListOnly
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Get-Headers {
  $h = @{ accept = 'application/json' }
  if ($ApiKey) {
    $h['X-N8N-API-KEY'] = $ApiKey
  }
  elseif ($BasicUser -and $BasicPass) {
    $pair = "{0}:{1}" -f $BasicUser, $BasicPass
    $b64  = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
    $h['Authorization'] = "Basic $b64"
  }
  else {
    throw "Provide N8N_API_KEY, or N8N_BASIC_AUTH_USER and N8N_BASIC_AUTH_PASSWORD."
  }
  return $h
}

if (-not $BaseUrl) { throw "Set N8N_BASE_URL or pass -BaseUrl." }
$BaseUrl = $BaseUrl.TrimEnd('/')

Write-Host "== 1) Health check $BaseUrl" -ForegroundColor Cyan
Invoke-WebRequest -Uri "$BaseUrl/healthz" -Headers (Get-Headers) -TimeoutSec 10 | Out-Null
Write-Host "   OK" -ForegroundColor Green

Write-Host "== 2) Fetch workflows" -ForegroundColor Cyan
$workflows = Invoke-RestMethod -Uri "$BaseUrl/rest/workflows" -Headers (Get-Headers) -Method GET
if (-not $workflows) { throw "No workflows returned." }

$targets = $workflows | Where-Object { $_.name -match [regex]::Escape($Match) }
if (-not $targets) {
  Write-Warning ("No workflows match: {0}" -f $Match)
  return
}

foreach ($w in $targets) {
  "{0,-50}  id={1}  active={2}" -f $w.name, $w.id, $w.active | Write-Host
}

if ($ListOnly) {
  Write-Host "== ListOnly: no activation" -ForegroundColor Yellow
  return
}

Write-Host "== 3) Activate matched workflows" -ForegroundColor Cyan
foreach ($t in $targets) {
  try {
    $body = @{ active = $true } | ConvertTo-Json
    Invoke-RestMethod `
      -Uri "$BaseUrl/rest/workflows/$($t.id)" `
      -Headers (Get-Headers) `
      -Method PATCH `
      -Body $body `
      -ContentType 'application/json' | Out-Null

    Write-Host ("   Activated: {0}" -f $t.id) -ForegroundColor Green
  }
  catch {
    Write-Warning ("   Activate failed id={0}: {1}" -f $t.id, $_.Exception.Message)
  }
}

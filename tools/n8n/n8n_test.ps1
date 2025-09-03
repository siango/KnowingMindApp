Param([string]$EnvFile = "tools\n8n\.env")

if (-not (Test-Path $EnvFile)) { Write-Error "Missing $EnvFile"; exit 1 }

Get-Content $EnvFile | ForEach-Object {
  if ($_ -match "^\s*#" -or $_.Trim() -eq "") { return }
  $parts = $_.Split("=",2)
  if ($parts.Count -eq 2) {
    [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1], "Process")
  }
}

$base = $env:N8N_BASE_URL.TrimEnd("/")
$headers = @{ accept = "application/json" }
if ($env:N8N_API_KEY) { $headers["X-N8N-API-KEY"] = $env:N8N_API_KEY }
if ($env:N8N_BASIC_AUTH_USER -and $env:N8N_BASIC_AUTH_PASSWORD) {
  $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($env:N8N_BASIC_AUTH_USER):$($env:N8N_BASIC_AUTH_PASSWORD)"))
  $headers["Authorization"] = "Basic $basic"
}

$url = "$base/api/v1/workflows"
Write-Host "GET $url"
Invoke-RestMethod -Uri $url -Headers $headers -Method GET | ConvertTo-Json -Depth 8

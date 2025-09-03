
Param([string]$EnvFile = "tools\n8n\.env")
if (-not (Test-Path $EnvFile)) { Write-Error "❌ ไม่พบไฟล์ $EnvFile"; exit 1 }
(Get-Content $EnvFile) | ForEach-Object {
  if ($_ -match "^\s*#" -or $_.Trim() -eq "") { return }
  $k,$v = $_.Split("=",2); $env:$k = $v
}
$headers = @{ accept = "application/json" }
if ($env:N8N_API_KEY) { $headers["X-N8N-API-KEY"] = $env:N8N_API_KEY }
if ($env:N8N_BASIC_AUTH_USER -and $env:N8N_BASIC_AUTH_PASSWORD) {
  $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($env:N8N_BASIC_AUTH_USER):$($env:N8N_BASIC_AUTH_PASSWORD)"))
  $headers["Authorization"] = "Basic $basic"
}
$url = "$($env:N8N_BASE_URL.TrimEnd('/'))/api/v1/workflows"
Invoke-RestMethod -Uri $url -Headers $headers -Method GET | ConvertTo-Json -Depth 6
Write-Host "✅ ทดสอบเรียก /api/v1/workflows เสร็จ"

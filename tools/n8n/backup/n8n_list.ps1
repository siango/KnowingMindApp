
Param(
  [string]$EnvFile = "tools\n8n\.env",
  [string]$Search
)
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
$base = $env:N8N_BASE_URL.TrimEnd("/")
$url  = "$base/api/v1/workflows"
$res  = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
$data = $res.data
if ($Search) { $data = $data | Where-Object { $_.name -like "*$Search*" } }
$data | Select-Object id, name, active, createdAt, updatedAt | Sort-Object name | Format-Table -AutoSize


Param([string]$EnvFile = "tools\n8n\.env")
if (-not (Test-Path $EnvFile)) { Write-Error "❌ ไม่พบไฟล์ $EnvFile"; exit 1 }
(Get-Content $EnvFile) | ForEach-Object {
  if ($_ -match "^\s*#" -or $_.Trim() -eq "") { return }
  $k,$v = $_.Split("=",2); $env:$k = $v
}
$headers = @{ accept = "application/json" }
if ($env:N8N_API_KEY) { $headers["X-N8N-API-KEY"] = $env:N8N_API_KEY }
$base = $env:N8N_BASE_URL.TrimEnd('/')
$urls = @("$base/api/v1/workflows","$base/")
foreach ($u in $urls) {
  try {
    Write-Host "▶ GET $u"
    $r = Invoke-WebRequest -Uri $u -Headers $headers -Method GET -UseBasicParsing -TimeoutSec 15
    Write-Host ("Status: {0}" -f $r.StatusCode)
  } catch {
    Write-Warning ("{0} : {1}" -f $u, $_.Exception.Message)
  }
}

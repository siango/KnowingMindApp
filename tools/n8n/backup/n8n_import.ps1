
Param(
  [string]$EnvFile = "tools\n8n\.env",
  [string]$File = "export_workflow.json",
  [switch]$UpdateIfExists
)
function Load-Env([string]$f) {
  if (-not (Test-Path $f)) { throw "❌ ไม่พบไฟล์ $f" }
  (Get-Content $f) | ForEach-Object {
    if ($_ -match "^\s*#" -or $_.Trim() -eq "") { return }
    $k,$v = $_.Split("=",2); $env:$k = $v
  }
}
function Build-Headers {
  $h = @{ accept = "application/json"; "Content-Type"="application/json" }
  if ($env:N8N_API_KEY) { $h["X-N8N-API-KEY"] = $env:N8N_API_KEY }
  return $h
}
try {
  Load-Env $EnvFile
  if (-not (Test-Path $File)) { throw "❌ ไม่พบไฟล์ $File" }
  $json = Get-Content $File -Raw | ConvertFrom-Json
  $base = $env:N8N_BASE_URL.TrimEnd("/")
  $headers = Build-Headers

  $payload = @{
    name = $json.name
    nodes = $json.nodes
    connections = $json.connections
    settings = $json.settings
    meta = $json.meta
    pinData = $json.pinData
    tags = $json.tags
    staticData = $json.staticData
  } | ConvertTo-Json -Depth 20

  $id = $json.id
  if ($UpdateIfExists -and $id) {
    $url = "$base/api/v1/workflows/$id"
    Write-Host "▶ PUT $url"
    $res = Invoke-RestMethod -Uri $url -Headers $headers -Method PUT -Body $payload
  } else {
    $url = "$base/api/v1/workflows"
    Write-Host "▶ POST $url"
    $res = Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $payload
  }

  $res | ConvertTo-Json -Depth 8
  Write-Host "✅ Import OK"
} catch { Write-Error $_.Exception.Message; exit 1 }

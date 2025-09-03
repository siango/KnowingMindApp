
Param(
  [string]$EnvFile = "tools\n8n\.env",
  [string]$Id,
  [string]$Name,
  [string]$OutFile = "export_workflow.json"
)
function Load-Env([string]$f) {
  if (-not (Test-Path $f)) { throw "❌ ไม่พบไฟล์ $f" }
  (Get-Content $f) | ForEach-Object {
    if ($_ -match "^\s*#" -or $_.Trim() -eq "") { return }
    $k,$v = $_.Split("=",2); $env:$k = $v
  }
}
function Build-Headers {
  $h = @{ accept = "application/json" }
  if ($env:N8N_API_KEY) { $h["X-N8N-API-KEY"] = $env:N8N_API_KEY }
  return $h
}
function Resolve-Id($base,$headers,$name) {
  $list = Invoke-RestMethod -Uri "$base/api/v1/workflows" -Headers $headers -Method GET
  $c = $list.data | Where-Object { $_.name -eq $name }
  if (-not $c) { $c = $list.data | Where-Object { $_.name -like "*$name*" } }
  if (-not $c) { throw "❌ หา workflow ชื่อ '$name' ไม่เจอ" }
  if ($c.Count -gt 1) { Write-Warning "พบหลายรายการ; ใช้ตัวแรก" }
  return $c[0].id
}
try {
  Load-Env $EnvFile
  $base = $env:N8N_BASE_URL.TrimEnd("/")
  $headers = Build-Headers
  if (-not $Id -and $Name) { $Id = Resolve-Id $base $headers $Name }
  if (-not $Id) { throw "โปรดระบุ -Id หรือ -Name" }
  $url = "$base/api/v1/workflows/$Id"
  Write-Host "▶ GET $url"
  $wf = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
  ($wf | ConvertTo-Json -Depth 10) | Out-File -Encoding UTF8 -FilePath $OutFile
  Write-Host "✅ Exported to $OutFile"
} catch { Write-Error $_.Exception.Message; exit 1 }


Param(
  [string]$EnvFile     = "tools\n8n\.env",
  [string]$Id,
  [string]$Name,
  [string]$PayloadJson,
  [string]$PayloadFile
)
function Load-Env {
  param([string]$f)
  if (-not (Test-Path $f)) { throw "❌ ไม่พบไฟล์ $f" }
  (Get-Content $f) | ForEach-Object {
    if ($_ -match "^\s*#" -or $_.Trim() -eq "") { return }
    $k,$v = $_.Split("=",2); $env:$k = $v
  }
}
function Build-Headers {
  $h = @{ accept = "application/json"; "Content-Type" = "application/json" }
  if ($env:N8N_API_KEY) { $h["X-N8N-API-KEY"] = $env:N8N_API_KEY }
  if ($env:N8N_BASIC_AUTH_USER -and $env:N8N_BASIC_AUTH_PASSWORD) {
    $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($env:N8N_BASIC_AUTH_USER):$($env:N8N_BASIC_AUTH_PASSWORD)"))
    $h["Authorization"] = "Basic $basic"
  }
  return $h
}
function Resolve-WorkflowId {
  param([string]$base, [hashtable]$headers, [string]$name)
  $list = Invoke-RestMethod -Uri "$base/api/v1/workflows" -Headers $headers -Method GET
  $candidates = $list.data | Where-Object { $_.name -eq $name }
  if (-not $candidates) { $candidates = $list.data | Where-Object { $_.name -like "*$name*" } }
  if (-not $candidates) { throw "❌ หา workflow ชื่อ '$name' ไม่เจอ" }
  if ($candidates.Count -gt 1) { Write-Warning "พบหลายรายการที่ชื่อคล้ายกัน; จะใช้ตัวแรก กรุณาระบุ -Id เพื่อความชัดเจน" }
  return $candidates[0].id
}
function Load-Payload {
  param([string]$json, [string]$file)
  if ($file) {
    if (-not (Test-Path $file)) { throw "❌ ไม่พบไฟล์ payload: $file" }
    return Get-Content $file -Raw | ConvertFrom-Json
  }
  if ($json) { return $json | ConvertFrom-Json }
  return @{} 
}
try {
  Load-Env -f $EnvFile
  $base = $env:N8N_BASE_URL.TrimEnd("/")
  $headers = Build-Headers
  if (-not $Id -and -not $Name) { throw "โปรดระบุ -Id หรือ -Name อย่างน้อยหนึ่งค่า" }
  if (-not $Id) { $Id = Resolve-WorkflowId -base $base -headers $headers -name $Name }
  $payloadObj = Load-Payload -json $PayloadJson -file $PayloadFile
  $body = @{ payload = $payloadObj } | ConvertTo-Json -Depth 20
  $url = "$base/api/v1/workflows/$Id/run"
  Write-Host "▶ POST $url"
  $res = Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $body
  $res | ConvertTo-Json -Depth 8
  Write-Host "✅ Triggered workflow id=$Id สำเร็จ"
} catch { Write-Error $_.Exception.Message; exit 1 }

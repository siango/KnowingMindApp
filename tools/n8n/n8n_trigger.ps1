Param(
  [string]$EnvFile     = "tools\n8n\.env",
  [string]$Id,
  [string]$Name,
  [string]$PayloadJson,
  [string]$PayloadFile
)

function Load-Env([string]$f) {
  if (-not (Test-Path $f)) { throw "Missing $f" }
  Get-Content $f | ForEach-Object {
    if ($_ -match "^\s*#" -or $_.Trim() -eq "") { return }
    $parts = $_.Split("=",2)
    if ($parts.Count -eq 2) {
      [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1], "Process")
    }
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

function Resolve-WorkflowId([string]$base, [hashtable]$headers, [string]$name) {
  $list = Invoke-RestMethod -Uri "$base/api/v1/workflows" -Headers $headers -Method GET
  $candidates = $list.data | Where-Object { $_.name -eq $name }
  if (-not $candidates) { $candidates = $list.data | Where-Object { $_.name -like "*$name*" } }
  if (-not $candidates) { throw "Workflow '$name' not found" }
  if ($candidates.Count -gt 1) { Write-Warning "Multiple matches; using the first. Use -Id for exact." }
  return $candidates[0].id
}

function Load-Payload([string]$json, [string]$file) {
  if ($file) {
    if (-not (Test-Path $file)) { throw "Payload file not found: $file" }
    return Get-Content $file -Raw | ConvertFrom-Json
  }
  if ($json) { return $json | ConvertFrom-Json }
  return @{}
}

try {
  Load-Env $EnvFile
  if (-not $Id -and -not $Name) { throw "Provide -Id or -Name" }

  $base = $env:N8N_BASE_URL.TrimEnd("/")
  $headers = Build-Headers
  if (-not $Id) { $Id = Resolve-WorkflowId -base $base -headers $headers -name $Name }

  $payloadObj = Load-Payload -json $PayloadJson -file $PayloadFile
  $body = @{ payload = $payloadObj } | ConvertTo-Json -Depth 20

  $url = "$base/api/v1/workflows/$Id/run"
  Write-Host "POST $url"
  $res = Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $body
  $res | ConvertTo-Json -Depth 8
  Write-Host "Triggered workflow id=$Id"
}
catch {
  Write-Error $_.Exception.Message
  exit 1
}

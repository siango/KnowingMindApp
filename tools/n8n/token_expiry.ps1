
Param([string]$Token)
if (-not $Token) { $Token = $env:N8N_API_KEY }
if (-not $Token) { Write-Error "❌ โปรดระบุ -Token หรือกำหนด N8N_API_KEY ใน .env"; exit 1 }
try {
  $parts = $Token.Split(".")
  if ($parts.Count -lt 2) { throw "ไม่ใช่ JWT" }
  $payload = $parts[1].Replace('-', '+').Replace('_', '/')
  switch ($payload.Length % 4) { 2{$payload+='=='} 3{$payload+='='} }
  $json = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload))
  $obj = $json | ConvertFrom-Json
  if ($obj.exp) {
    $dt = [DateTimeOffset]::FromUnixTimeSeconds([int64]$obj.exp).LocalDateTime
    Write-Host ("exp: {0}  (local time)" -f $dt.ToString("yyyy-MM-dd HH:mm:ss"))
  } else {
    Write-Host $json
  }
} catch { Write-Error $_.Exception.Message; exit 1 }

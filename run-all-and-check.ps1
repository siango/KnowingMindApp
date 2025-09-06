# run-all-and-check.ps1
$ErrorActionPreference = "Stop"
$root = "C:\AndroidProjects\KnowingMindSuite"

# shell path (PS5-compatible)
$cmd = Get-Command pwsh -ErrorAction SilentlyContinue
$shellPath = if ($cmd) { $cmd.Path } else { (Get-Command powershell.exe -ErrorAction SilentlyContinue).Path }
if (-not $shellPath) { throw "ไม่พบทั้ง 'pwsh' และ 'powershell.exe' ใน PATH" }

function Start-Dev($relPath) {
  $abs = Join-Path $root $relPath
  if (-not (Test-Path $abs)) { throw "ไม่พบโฟลเดอร์: $abs" }
  Start-Process -FilePath $shellPath -WorkingDirectory $abs `
    -ArgumentList @("-NoExit","-Command","cd `"$abs`"; pnpm run dev") | Out-Null
}

# 1) start services
Start-Dev "services\arunroo-ics"
Start-Dev "services\satishift-webhook"
Start-Dev "services\kma-api"

# 2) health check with retry
$urls = @(
  "http://localhost:8080/api/ping",
  "http://localhost:8081/api/ping",
  "http://localhost:8082/api/ping"
)
$max = 8
for($i=1; $i -le $max; $i++){
  $ok = $true
  foreach($u in $urls){
    try{
      $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 6
      Write-Host "[$i/$max] $u -> $($r.StatusCode)" -ForegroundColor Green
    } catch {
      $ok = $false
      Write-Host "[$i/$max] $u -> $($_.Exception.Message)" -ForegroundColor Yellow
    }
  }
  if($ok){ break } else { Start-Sleep -Milliseconds (800 + ($i*200)) }
}

Write-Host "`nดู log สด:" -ForegroundColor Cyan
Write-Host "  - arunroo-ics:     cd services\arunroo-ics;     tail -f .\pnpm-debug.log (ถ้ามี)" -ForegroundColor DarkCyan
Write-Host "  - satishift-webhook: cd services\satishift-webhook; tail -f .\pnpm-debug.log" -ForegroundColor DarkCyan
Write-Host "  - kma-api:          cd services\kma-api;          tail -f .\pnpm-debug.log" -ForegroundColor DarkCyan

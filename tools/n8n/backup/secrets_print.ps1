
Param([string]$EnvFile = "tools\n8n\.env")
if (-not (Test-Path $EnvFile)) { Write-Error "❌ ไม่พบไฟล์ $EnvFile"; exit 1 }
Get-Content $EnvFile | ForEach-Object {
  if ($_ -match "^\s*#" -or $_.Trim() -eq "") { return }
  ($_.Split("=",2)[0]) + "=******"
}

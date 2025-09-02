# stop-all.ps1
Get-Process -Name node,tsx -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "Stopped node/tsx dev processes." -ForegroundColor Cyan

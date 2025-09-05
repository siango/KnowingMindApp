[CmdletBinding()]
param(
  [string]$Path=".",
  [int]$DaysOld=30,
  [switch]$IncludeNodeModules,
  [switch]$Execute
)
if(!(Test-Path $Path)){ throw "Path not found: $Path" }
$cutoff = (Get-Date).AddDays(-$DaysOld)
Write-Host "== SafeClean start: $Path  (older than $DaysOld days)"
$dirs=@(".git",".gradle",".idea","build","dist","out",".angular","coverage",".next",".vite","target")
if($IncludeNodeModules){ $dirs += "node_modules","pnpm-store" }
$removeDirs=@()
Get-ChildItem -Path $Path -Recurse -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
  if($dirs -contains $_.Name){ $removeDirs += $_.FullName }
}
$removeFiles = Get-ChildItem -Path $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.LastWriteTime -lt $cutoff -and $_.Extension -in @(".log",".tmp",".bak",".old",".cache") } |
  Select-Object -ExpandProperty FullName
Write-Host "-- Candidates (directories):"
$removeDirs | Sort-Object -Unique | ForEach-Object { Write-Host "   $_" }
Write-Host "-- Candidates (files):"
$removeFiles | Sort-Object -Unique | ForEach-Object { Write-Host "   $_" }
if($Execute){
  Write-Host "Executing deletion..."
  foreach($p in ($removeDirs | Sort-Object -Unique)){ try{ Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction Stop } catch { Write-Host "Failed: $p ($_)" } }
  foreach($p in ($removeFiles | Sort-Object -Unique)){ try{ Remove-Item -LiteralPath $p -Force -ErrorAction Stop } catch { Write-Host "Failed: $p ($_)" } }
  Write-Host "Done."
} else {
  Write-Host "Dry-Run only. Add -Execute to actually remove."
}

# ai_agents_tasks_osp_ascii.ps1 — robust (ASCII only) version
# Creates today's task list (MD + TXT) and auto-copies ai_agents_bundle_v1.zip to Downloads.

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$today = (Get-Date).ToString('yyyy-MM-dd')
$root  = Join-Path $HOME "ai_agents_tasks"
if (!(Test-Path $root)) { New-Item -ItemType Directory -Force -Path $root | Out-Null }

$md  = Join-Path $root ("tasks_{0}.md" -f $today)
$txt = Join-Path $root ("todo_{0}.txt" -f $today)

$mdBody = @"
# ✅ Today's Work (AI Agents — Day 1)
**Date:** $today  (Asia/Bangkok)

## Goals
- Feedback Agent — collect metrics: success/fail, latency, CTR, completion
- Orchestrator Agent — route / retry / fallback, connect to n8n or existing workflow

## Checklist
- [ ] Backup baseline zip (ai_agents_bundle_v1.zip) to Downloads
- [ ] Feedback Agent: service stub + endpoints
- [ ] Metrics pipeline to Firestore/Sheets + unified log format
- [ ] Orchestrator: route -> exec -> retry -> fallback
- [ ] One end-to-end test and record result in logs
- [ ] Update roadmap.md: Month-1 started
- [ ] Git tag: ai-agents-v1.1-start-$today

## Notes
- Do not break existing systems; add layers only
- If time allows: tiny dashboard for latency/success rate
"@

$txtBody = @"
[ ] Backup v1 zip to Downloads
[ ] Feedback Agent stub + endpoints
[ ] Metrics -> Firestore/Sheets + unified log
[ ] Orchestrator route->exec->retry->fallback
[ ] One end-to-end test + log result
[ ] Update roadmap.md: Month-1 started
[ ] Git tag: ai-agents-v1.1-start-$today
"@

Set-Content $md  $mdBody  -Encoding UTF8
Set-Content $txt $txtBody -Encoding UTF8

# --- Auto Backup ZIP (robust Downloads detection) ---
$srcZip = Join-Path $HOME "ai_agents_bundle_v1.zip"
$downloads = Join-Path $HOME "Downloads"
if (-not (Test-Path $downloads)) {
  try { $downloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path } catch {}
}
if (-not (Test-Path $downloads)) { $downloads = [Environment]::GetFolderPath('Desktop') }
$dstZip = Join-Path $downloads "ai_agents_bundle_v1.zip"

if (Test-Path $srcZip) {
  Copy-Item $srcZip $dstZip -Force
  Write-Host ">>> Backup complete: $dstZip" -ForegroundColor Green
} else {
  Write-Host ">>> WARNING: Source zip not found: $srcZip" -ForegroundColor Red
}

Write-Host ">>> Created:" -ForegroundColor Cyan
Write-Host " - $md"  -ForegroundColor Green
Write-Host " - $txt" -ForegroundColor Green

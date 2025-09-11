# ai_agents_tasks_osp.ps1 — Create today's task list for AI Agents Day 1 (Bangkok)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$today = "2025-09-11"
$root  = Join-Path $HOME "ai_agents_tasks"
if (!(Test-Path $root)) { New-Item -ItemType Directory -Force -Path $root | Out-Null }

$md = Join-Path $root ("tasks_{0}.md" -f $today)
$txt = Join-Path $root ("todo_{0}.txt" -f $today)

@"
# ✅ งานวันนี้ (AI Agents — Day 1)

**วันที่:** 2025-09-11  (Asia/Bangkok)

## เป้าหมายวันนี้
- ตั้งต้น **Feedback Agent** (เวทนา) — เก็บ metrics: success/fail, latency, CTR, completion
- ตั้งต้น **Orchestrator Agent** (สังขาร) — route/retry/fallback ผูกกับ n8n หรือ Workflow เดิม

## เช็กลิสต์
- [ ] สำรอง baseline ล่าสุดเป็น `ai_agents_bundle_v1.zip` ไป %USERPROFILE%\Downloads\
- [ ] สร้างโครง Feedback Agent (service stub + endpoints)
- [ ] เก็บ metrics เบื้องต้นลง Firestore/Sheets และ log format เดียวกัน
- [ ] สร้าง Orchestrator flow (route → exec → retry → fallback)
- [ ] ทดสอบ 1 เคส end-to-end พร้อมบันทึกผลใน logs
- [ ] อัปเดต `roadmap.md` ว่าเริ่ม Month-1 แล้ว
- [ ] แท็ก repo: `ai-agents-v1.1-start-2025-09-11`

## หมายเหตุ
- อย่ารื้อของเดิม—เพิ่ม layer เท่านั้น
- ถ้ามีเวลา: ทำ dashboard เล็ก ๆ (latency/success rate)
"@ | Set-Content $md -Encoding UTF8

@"
[ ] Backup v1 zip to %USERPROFILE%\Downloads\
[ ] Feedback Agent stub + endpoints
[ ] Metrics to Firestore/Sheets + unified log
[ ] Orchestrator route->exec->retry->fallback
[ ] One end-to-end test + log result
[ ] Update roadmap.md: Month-1 started
[ ] Git tag: ai-agents-v1.1-start-2025-09-11
"@ | Set-Content $txt -Encoding UTF8

Write-Host ">>> Created:" -ForegroundColor Cyan
Write-Host " - $md" -ForegroundColor Green
Write-Host " - $txt" -ForegroundColor Green
Write-Host ">>> Preview (first lines):" -ForegroundColor Cyan
Get-Content $md -TotalCount 30

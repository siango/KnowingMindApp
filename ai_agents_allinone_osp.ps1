# ai_agents_allinone_osp.ps1 — One-Shot PowerShell (ALL-IN-ONE, Full Table)
# Build bundle (files + SVG + baseline marker), zip, and verify in one step

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Root    = Join-Path $HOME "ai_agents_bundle"
$Zip     = Join-Path $HOME "ai_agents_bundle.zip"
$ZipV1   = Join-Path $HOME "ai_agents_bundle_v1.zip"

function Say($m, $c="Cyan"){ Write-Host ">>> $m" -ForegroundColor $c }

# Prepare folder
if (!(Test-Path $Root)) { New-Item -ItemType Directory -Force -Path $Root | Out-Null }

# README
@"
# AI Agents & ขันธ์ห้า (Samsara Pack)

เอกสารสถาปัตย์ AI เทียบ **ขันธ์ 5** และ **ปฏิจจสมุปบาท**:
- roadmap.md — 1–3–6 month roadmap
- agents_table.md — ตาราง 12 Agents
- agents_flow.mmd — Mermaid diagram
- cycle_diagram.svg — แผนภาพวงกลม
- agents_baseline_v1.md — baseline marker
"@ | Set-Content "$Root\README.md" -Encoding UTF8

# Roadmap
@"
# 📅 Roadmap AI Agents ↔ ขันธ์ห้า

## เดือนที่ 1
- Feedback Agent (เวทนา)
- Orchestrator Agent (สังขาร)

## เดือนที่ 3
- Memory Agent (สัญญา)
- Tool Executor (สังขาร)
- Safety Guard (เวทนา+สังขาร)
- Quality & Eval Lab (เวทนา)

## เดือนที่ 6
- Multimodal Perception (วิญญาณ)
- Persona/Profile Manager (สัญญา)
- Observability & Cost Controller (รูป)
- Scheduler & Event Bus (รูป)
"@ | Set-Content "$Root\roadmap.md" -Encoding UTF8

# Agents Table (FULL)
@"
# 🧩 12 AI Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท

| #  | Agent                   | ขันธ์         | หน้าที่หลัก             | ลำดับ | ปฏิจจสมุปบาท          |
|----|-------------------------|---------------|--------------------------|-------|------------------------|
| 1  | Scheduler & Event Bus   | รูป           | trigger/pub-sub          | 1     | อวิชชา → สังขาร       |
| 2  | Perception Hub          | วิญญาณ       | รับอินพุต                | 2     | วิญญาณ                 |
| 3  | Multimodal Perception   | วิญญาณ       | STT/OCR/ภาพ/วิดีโอ      | 3     | นามรูป                 |
| 4  | Memory & Knowledge      | สัญญา        | context/knowledge        | 4     | สัญญา                  |
| 5  | Persona/Profile Manager | สัญญา        | บุคลิก/โทน/แบรนด์      | 5     | อุปาทาน                |
| 6  | Reasoner & Planner      | สังขาร       | วิเคราะห์/วางแผน        | 6     | สังขาร                  |
| 7  | Tool/Action Executor    | สังขาร       | เรียกเครื่องมือจริง      | 7     | ภพ                      |
| 8  | Workflow Orchestrator   | สังขาร       | คุมลำดับ/retry           | 8     | ชาติ                    |
| 9  | Feedback & Preference   | เวทนา        | ให้คะแนน/ความพึงพอใจ    | 9     | เวทนา                   |
| 10 | Safety & Policy Guard   | เวทนา+สังขาร | Policy/PDPA/Quota        | 10    | ตัณหา/วิภวตัณหา       |
| 11 | Quality & Eval Lab      | เวทนา        | golden set/regression    | 11    | วิญญาณ + เวทนา        |
| 12 | Observability & Cost    | รูป           | monitor/metrics/cost     | 12    | ชรา–มรณะ              |
"@ | Set-Content "$Root\agents_table.md" -Encoding UTF8

# Flow (Mermaid)
@"
flowchart LR
  SCH[Scheduler (อวิชชา)] --> PER[Perception (วิญญาณ)]
  PER --> MMP[Multimodal (นามรูป)]
  MMP --> MEM[Memory (สัญญา)]
  MEM --> PERM[Persona (อุปาทาน)]
  PERM --> RSN[Reasoner (สังขาร)]
  RSN --> EXE[Executor (ภพ)]
  EXE --> ORC[Orchestrator (ชาติ)]
  ORC --> FDB[Feedback (เวทนา)]
  FDB --> SAF[Safety (ตัณหา)]
  SAF --> QAL[Quality (ประเมิน)]
  QAL --> OBS[Observability (ชรา-มรณะ)]
  OBS --> SCH
"@ | Set-Content "$Root\agents_flow.mmd" -Encoding UTF8

# Simple SVG cycle
@"
<svg xmlns='http://www.w3.org/2000/svg' width='800' height='800'>
  <circle cx='400' cy='400' r='350' fill='none' stroke='gray' stroke-width='2'/>
  <text x='400' y='40' text-anchor='middle' font-size='20'>12 Agents ↔ ปฏิจจสมุปบาท</text>
</svg>
"@ | Set-Content "$Root\cycle_diagram.svg" -Encoding UTF8

# Baseline marker
@"
# 🪷 AI Agents Baseline v1 (2025-09-11)
- Design Pack: AI Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท
- Files: README.md, roadmap.md, agents_table.md, agents_flow.mmd, cycle_diagram.svg
- ใช้เป็น baseline สำหรับการต่อยอด
"@ | Set-Content "$Root\agents_baseline_v1.md" -Encoding UTF8

# Zip
if (Test-Path $Zip) { Remove-Item $Zip -Force }
Compress-Archive -Path "$Root\*" -DestinationPath $Zip
if (Test-Path $ZipV1) { Remove-Item $ZipV1 -Force }
Copy-Item $Zip $ZipV1

# Verify
$req = @("README.md","roadmap.md","agents_table.md","agents_flow.mmd","cycle_diagram.svg","agents_baseline_v1.md")
foreach($f in $req){
  if(Test-Path (Join-Path $Root $f)){ Say "FOUND: $f" "Green" } else { Say "MISSING: $f" "Red" }
}
if(Test-Path $Zip){ Say "FOUND ZIP: $Zip" "Green" }
if(Test-Path $ZipV1){ Say "FOUND ZIP v1: $ZipV1" "Green" }

Say "ALL DONE. Folder: $Root"

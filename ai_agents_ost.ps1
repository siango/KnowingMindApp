# ai_agents_ost.ps1 — One-Shot PowerShell: Generate AI Agents baseline bundle
$ErrorActionPreference = "Stop"

$Root = "$HOME\ai_agents_bundle"
$Zip  = "$HOME\ai_agents_bundle.zip"

function Say($msg){ Write-Host ">>> $msg" -ForegroundColor Cyan }

# 1. Create directory
if (!(Test-Path $Root)) { New-Item -ItemType Directory -Force -Path $Root | Out-Null }

# 2. README.md
@"
# AI Agents & ขันธ์ห้า (Samsara Pack)

ชุดเอกสารอธิบายสถาปัตย์ AI แบบเทียบ **ขันธ์ 5** และวงจร **ปฏิจจสมุปบาท**:
- roadmap.md — โรดแมป 1–3–6 เดือน
- agents_table.md — ตาราง 12 Agents
- agents_flow.mmd — ผัง Mermaid (ดูบน GitHub/VS Code/Obsidian)
- cycle_diagram.svg — แผนภาพวงกลม
"@ | Set-Content "$Root\README.md" -Encoding UTF8

# 3. roadmap.md
@"
# 📅 Roadmap AI Agents ↔ ขันธ์ห้า

## เดือนที่ 1
- Feedback Agent (เวทนา)
- Orchestrator Agent (สังขาร)

## เดือนที่ 3
- Memory Agent (สัญญา)
- Safety Guard (เวทนา+สังขาร)
- Quality & Eval Lab (เวทนา)
- Tool Executor (สังขาร)

## เดือนที่ 6
- Multimodal Perception (วิญญาณ)
- Persona Manager (สัญญา)
- Observability & Cost Controller (รูป)
- Scheduler/Event Bus (รูป)
"@ | Set-Content "$Root\roadmap.md" -Encoding UTF8

# 4. agents_table.md
@"
# 🧩 12 AI Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท

| Agent | ขันธ์ | หน้าที่หลัก | ปฏิจจสมุปบาท |
|-------|-------|-------------|---------------|
| Scheduler/Event Bus | รูป | trigger | อวิชชา |
| Perception Hub | วิญญาณ | รับอินพุต | วิญญาณ |
| Multimodal | วิญญาณ | รวมสัญญาณ | นามรูป |
| Memory | สัญญา | ความจำ | สัญญา |
| Persona | สัญญา | บุคลิก | อุปาทาน |
| Reasoner | สังขาร | วางแผน | สังขาร |
| Executor | สังขาร | ทำงานจริง | ภพ |
| Orchestrator | สังขาร | คุมลำดับ | ชาติ |
| Feedback | เวทนา | คะแนน | เวทนา |
| Safety | เวทนา+สังขาร | policy | ตัณหา |
| Quality | เวทนา | ทดสอบ | วิญญาณ+เวทนา |
| Observability | รูป | monitor | ชรา–มรณะ |
"@ | Set-Content "$Root\agents_table.md" -Encoding UTF8

# 5. agents_flow.mmd
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

# 6. cycle_diagram.svg (simple placeholder)
@"
<svg xmlns='http://www.w3.org/2000/svg' width='600' height='600'>
  <circle cx='300' cy='300' r='280' fill='none' stroke='gray' stroke-width='2'/>
  <text x='300' y='40' text-anchor='middle' font-size='20'>วงจร 12 Agents ↔ ปฏิจจสมุปบาท</text>
  <text x='300' y='580' text-anchor='middle' font-size='14'>Baseline v1 (2025-09-11)</text>
</svg>
"@ | Set-Content "$Root\cycle_diagram.svg" -Encoding UTF8

# 7. baseline marker
@"
# 🪷 AI Agents Baseline v1 (2025-09-11)

- Design Pack: AI Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท
- ไฟล์รวม: README.md, roadmap.md, agents_table.md, agents_flow.mmd, cycle_diagram.svg
- ใช้เป็น baseline อ้างอิงต่อยอดครั้งถัดไป
"@ | Set-Content "$Root\agents_baseline_v1.md" -Encoding UTF8

# 8. Create ZIP
if (Test-Path $Zip) { Remove-Item $Zip -Force }
Compress-Archive -Path "$Root\*" -DestinationPath $Zip

Say "สร้าง bundle เสร็จแล้ว:"
Say " - Folder: $Root"
Say " - Zip:    $Zip"

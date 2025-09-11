# ai_agents_osp.ps1 — One-Shot PowerShell (รวมทั้งหมด)
# สร้างชุดเอกสาร 12 Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท + ZIP + ตรวจสอบ
# ใช้ได้บน Windows PowerShell/Terminal โดยไม่ต้องติดตั้งอะไรเพิ่ม

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Root = Join-Path $HOME "ai_agents_bundle"
$Zip  = Join-Path $HOME "ai_agents_bundle.zip"
$ZipV = Join-Path $HOME "ai_agents_bundle_v1.zip"

function Say($m, $c="Cyan"){ Write-Host ">>> $m" -ForegroundColor $c }

# 0) เตรียมโฟลเดอร์
if (!(Test-Path $Root)) { New-Item -ItemType Directory -Force -Path $Root | Out-Null }

# 1) README.md
@"
# AI Agents & ขันธ์ห้า (Samsara Pack)

ชุดเอกสารอธิบายสถาปัตย์ AI เทียบ **ขันธ์ 5** และวงจร **ปฏิจจสมุปบาท**:
- `roadmap.md` — โรดแมป 1–3–6 เดือน (จาก 5 → 8 → 12 agents)
- `agents_table.md` — ตาราง 12 Agents: หน้าที่, ลำดับ, ปฏิจจสมุปบาท
- `agents_flow.mmd` — ผัง Mermaid (ดูบน GitHub/VS Code/Obsidian)
- `cycle_diagram.svg` — แผนภาพวงกลม (วาดด้วย SVG ตรง ๆ)
"@ | Set-Content "$Root\README.md" -Encoding UTF8

# 2) roadmap.md
@"
# 📅 Roadmap AI Agents ↔ ขันธ์ห้า

## ปัจจุบัน (MVP 5 ตัว)
- รูป: Cloud Run, Firestore, Pub/Sub, Scheduler
- เวทนา: manual feedback/logs
- สัญญา: Firestore + Sheets + Docs
- สังขาร: GPT + n8n
- วิญญาณ: NLP (ข้อความ)

## เดือนที่ 1 — เสริมเวทนา+สังขารพื้นฐาน
- Feedback Agent (เวทนา): metrics (success/fail, latency, CTR, completion, donation)
- Orchestrator Agent (สังขาร): route, retry, fallback (n8n/Workflows)

## เดือนที่ 3 — 8 Agents มาตรฐาน
- Memory Agent (สัญญา)
- Tool Executor (สังขาร)
- Safety & Policy Guard (เวทนา+สังขาร)
- Quality & Eval Lab (เวทนา)
- DataOps/Monitor (รูป)

## เดือนที่ 6 — 12 Agents (องค์กร)
- Multimodal Perception (วิญญาณ)
- Persona/Profile Manager (สัญญา)
- Observability & Cost Controller (รูป)
- Scheduler & Event Bus (รูป)
"@ | Set-Content "$Root\roadmap.md" -Encoding UTF8

# 3) agents_table.md
@"
# 🧩 12 AI Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท

| # | Agent | ขันธ์ | หน้าที่หลัก | ลำดับ | ปฏิจจสมุปบาท |
|---|-------|-------|-------------|-------|---------------|
| 1 | Scheduler & Event Bus | รูป | trigger event/pub-sub | 1 | อวิชชา → สังขาร |
| 2 | Perception Hub | วิญญาณ | รับอินพุตข้อความ/สัญญาณ | 2 | วิญญาณ |
| 3 | Multimodal Perception | วิญญาณ | STT/OCR/ภาพ/วิดีโอ | 3 | นามรูป |
| 4 | Memory & Knowledge | สัญญา | context/knowledge | 4 | สัญญา |
| 5 | Persona/Profile Manager | สัญญา | โทน/บุคลิก/แบรนด์ | 5 | อุปาทาน |
| 6 | Reasoner & Planner | สังขาร | วิเคราะห์/วางแผน | 6 | สังขาร |
| 7 | Tool/Action Executor | สังขาร | เรียกเครื่องมือจริง | 7 | ภพ |
| 8 | Workflow Orchestrator | สังขาร | คุมลำดับ/retry | 8 | ชาติ |
| 9 | Feedback & Preference | เวทนา | คะแนนดี/แย่ | 9 | เวทนา |
|10 | Safety & Policy Guard | เวทนา+สังขาร | PDPA/Content/RBAC/Quota | 10 | ตัณหา/วิภวตัณหา |
|11 | Quality & Eval Lab | เวทนา | golden set/regression | 11 | วิญญาณ+เวทนา |
|12 | Observability & Cost Ctrl | รูป | metrics/logs/cost alert | 12 | ชรา–มรณะ |
"@ | Set-Content "$Root\agents_table.md" -Encoding UTF8

# 4) agents_flow.mmd
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

# 5) cycle_diagram.svg (Samsara-like)
@"
<?xml version='1.0' encoding='UTF-8'?>
<svg width='1200' height='1200' viewBox='0 0 1200 1200' xmlns='http://www.w3.org/2000/svg'>
  <defs>
    <marker id='arrow' markerWidth='12' markerHeight='12' refX='10' refY='6' orient='auto'>
      <path d='M0,0 L12,6 L0,12 z' fill='#333'/>
    </marker>
    <style>
      .node { fill:#E0F7FA; stroke:#1890a0; stroke-width:2; rx:18; ry:18; }
      .edge { stroke:#333; stroke-width:2; fill:none; marker-end:url(#arrow); }
      .label { font-family: sans-serif; font-size: 16px; fill:#111; }
      .title { font-family: sans-serif; font-size: 28px; font-weight: bold; fill:#111; }
      .subtitle { font-family: sans-serif; font-size: 16px; fill:#444; }
    </style>
  </defs>
  <text x='600' y='70' text-anchor='middle' class='title'>วงจร 12 Agents ↔ ปฏิจจสมุปบาท (Samsara-like)</text>
  <text x='600' y='96' text-anchor='middle' class='subtitle'>Scheduler → Perception → Memory → Reasoner → Executor → Orchestrator → Feedback → Safety → Quality → Observability → Scheduler</text>
  <circle cx='600' cy='620' r='480' fill='none' stroke='#ddd' stroke-width='2'/>
  <!-- 12 กล่องรอบวง -->
  <rect class='node' x='520' y='120' width='160' height='70'/><text class='label' x='600' y='145' text-anchor='middle'>Scheduler / Event</text><text class='label' x='600' y='167' text-anchor='middle'>(อวิชชา)</text>
  <rect class='node' x='760' y='170' width='180' height='70'/><text class='label' x='850' y='195' text-anchor='middle'>Perception Hub</text><text class='label' x='850' y='217' text-anchor='middle'>(วิญญาณ)</text>
  <rect class='node' x='930' y='310' width='190' height='70'/><text class='label' x='1025' y='335' text-anchor='middle'>Multimodal</text><text class='label' x='1025' y='357' text-anchor='middle'>(นามรูป)</text>
  <rect class='node' x='1010' y='500' width='170' height='70'/><text class='label' x='1095' y='525' text-anchor='middle'>Memory/Knowledge</text><text class='label' x='1095' y='547' text-anchor='middle'>(สัญญา)</text>
  <rect class='node' x='960' y='700' width='180' height='70'/><text class='label' x='1050' y='725' text-anchor='middle'>Persona/Profile</text><text class='label' x='1050' y='747' text-anchor='middle'>(อุปาทาน)</text>
  <rect class='node' x='770' y='850' width='180' height='70'/><text class='label' x='860' y='875' text-anchor='middle'>Reasoner/Planner</text><text class='label' x='860' y='897' text-anchor='middle'>(สังขาร)</text>
  <rect class='node' x='520' y='900' width='160' height='70'/><text class='label' x='600' y='925' text-anchor='middle'>Tool / Executor</text><text class='label' x='600' y='947' text-anchor='middle'>(ภพ)</text>
  <rect class='node' x='300' y='850' width='180' height='70'/><text class='label' x='390' y='875' text-anchor='middle'>Orchestrator</text><text class='label' x='390' y='897' text-anchor='middle'>(ชาติ)</text>
  <rect class='node' x='130' y='700' width='190' height='70'/><text class='label' x='225' y='725' text-anchor='middle'>Feedback/Preference</text><text class='label' x='225' y='747' text-anchor='middle'>(เวทนา)</text>
  <rect class='node' x='60' y='500' width='190' height='70'/><text class='label' x='155' y='525' text-anchor='middle'>Safety/Policy Guard</text><text class='label' x='155' y='547' text-anchor='middle'>(ตัณหา)</text>
  <rect class='node' x='80' y='310' width='180' height='70'/><text class='label' x='170' y='335' text-anchor='middle'>Quality & Eval</text><text class='label' x='170' y='357' text-anchor='middle'>(ประเมิน)</text>
  <rect class='node' x='280' y='170' width='190' height='70'/><text class='label' x='375' y='195' text-anchor='middle'>Observability / Cost</text><text class='label' x='375' y='217' text-anchor='middle'>(ชรา-มรณะ)</text>
  <!-- เส้นลูกศร -->
  <path class='edge' d='M600,190 C640,210 710,210 760,205' />
  <path class='edge' d='M940,205 C980,220 1000,255 1025,310' />
  <path class='edge' d='M1025,380 C1060,430 1090,460 1095,500' />
  <path class='edge' d='M1095,570 C1085,620 1080,660 1050,700' />
  <path class='edge' d='M960,735 C920,770 900,820 860,850' />
  <path class='edge' d='M860,920 C800,940 700,945 680,935' />
  <path class='edge' d='M520,935 C480,940 430,925 390,895' />
  <path class='edge' d='M300,885 C260,870 230,820 225,770' />
  <path class='edge' d='M225,700 C215,660 200,610 155,570' />
  <path class='edge' d='M155,500 C150,460 150,420 170,380' />
  <path class='edge' d='M170,310 C210,250 270,225 330,205' />
  <path class='edge' d='M470,205 C520,205 560,190 600,190' />
</svg>
"@ | Set-Content "$Root\cycle_diagram.svg" -Encoding UTF8

# 6) baseline marker
@"
# 🪷 AI Agents Baseline v1 (2025-09-11)
- Design Pack: AI Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท
- รวมไฟล์: README.md, roadmap.md, agents_table.md, agents_flow.mmd, cycle_diagram.svg
- ใช้เป็น baseline อ้างอิงต่อยอดครั้งถัดไป
"@ | Set-Content "$Root\agents_baseline_v1.md" -Encoding UTF8

# 7) สร้าง ZIP (latest) และ ZIP รุ่น v1
if (Test-Path $Zip) { Remove-Item $Zip -Force }
Compress-Archive -Path "$Root\*" -DestinationPath $Zip
if (Test-Path $ZipV) { Remove-Item $ZipV -Force }
Copy-Item $Zip $ZipV

# 8) VERIFY — ตรวจสอบความครบถ้วน
$req = @("README.md","roadmap.md","agents_table.md","agents_flow.mmd","cycle_diagram.svg","agents_baseline_v1.md")
$missing = @()
foreach($f in $req){
  if(Test-Path (Join-Path $Root $f)){ Say "พบไฟล์: $f" "Green" } else { Say "ขาดไฟล์: $f" "Red"; $missing += $f }
}
if(Test-Path $Zip){ Say "พบ ZIP: $Zip" "Green" } else { Say "ไม่พบ ZIP: $Zip" "Red" }
if(Test-Path $ZipV){ Say "พบ ZIP (v1): $ZipV" "Green" } else { Say "ไม่พบ ZIP (v1): $ZipV" "Red" }

# keyword check
if(Select-String -Quiet -Pattern "Roadmap AI Agents" -Path "$Root\roadmap.md"){ Say "roadmap.md: OK keyword" "Green" } else { Say "roadmap.md: missing keyword" "Yellow" }
if(Select-String -Quiet -Pattern "12 AI Agents" -Path "$Root\agents_table.md"){ Say "agents_table.md: OK keyword" "Green" } else { Say "agents_table.md: missing keyword" "Yellow" }
if(Select-String -Quiet -Pattern "flowchart" -Path "$Root\agents_flow.mmd"){ Say "agents_flow.mmd: OK mermaid" "Green" } else { Say "agents_flow.mmd: missing mermaid" "Yellow" }

Say "สร้าง bundle เสร็จแล้ว:" "Cyan"
Say (" - Folder: {0}" -f $Root) "Cyan"
Say (" - Zip:    {0}" -f $Zip) "Cyan"
Say (" - Zip v1: {0}" -f $ZipV) "Cyan"

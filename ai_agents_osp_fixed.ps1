# ai_agents_osp_fixed.ps1 — One-Shot PowerShell (UTF-8 safe)
# Build bundle (files + SVG), add baseline marker, zip, and verify.

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Root = Join-Path $HOME "ai_agents_bundle"
$ZipLatest = Join-Path $HOME "ai_agents_bundle.zip"
$ZipV1     = Join-Path $HOME "ai_agents_bundle_v1.zip"

function Say($m, $c="Cyan"){ Write-Host ">>> $m" -ForegroundColor $c }

# 0) Prepare folder
if (!(Test-Path $Root)) { New-Item -ItemType Directory -Force -Path $Root | Out-Null }

# 1) README.md
@"
# AI Agents & ขันธ์ห้า (Samsara Pack)

เอกสารสถาปัตย์ AI เทียบ **ขันธ์ 5** และ **ปฏิจจสมุปบาท**:
- `roadmap.md` — โรดแมป 1–3–6 เดือน
- `agents_table.md` — 12 Agents
- `agents_flow.mmd` — Mermaid diagram
- `cycle_diagram.svg` — แผนภาพวงกลม
"@ | Set-Content "$Root\README.md" -Encoding UTF8

# 2) roadmap.md
@"
# 📅 Roadmap AI Agents ↔ ขันธ์ห้า

## ปัจจุบัน (MVP 5)
- รูป: Cloud Run/Firestore/PubSub/Scheduler
- เวทนา: manual logs
- สัญญา: Firestore + Sheets + Docs
- สังขาร: GPT + n8n
- วิญญาณ: NLP (ข้อความ)

## เดือนที่ 1
- Feedback Agent (metrics)
- Orchestrator Agent (route/retry/fallback)

## เดือนที่ 3
- Memory Agent, Tool Executor
- Safety Guard, Quality & Eval
- DataOps/Monitor

## เดือนที่ 6
- Multimodal Perception
- Persona/Profile Manager
- Observability & Cost Controller
- Scheduler & Event Bus
"@ | Set-Content "$Root\roadmap.md" -Encoding UTF8

# 3) agents_table.md
@"
# 🧩 12 AI Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท

| # | Agent | ขันธ์ | หน้าที่ | ลำดับ | ปฏิจจสมุปบาท |
|---|-------|-------|---------|-------|---------------|
| 1 | Scheduler & Event Bus | รูป | trigger/pub-sub | 1 | อวิชชา→สังขาร |
| 2 | Perception Hub | วิญญาณ | รับอินพุต | 2 | วิญญาณ |
| 3 | Multimodal Perception | วิญญาณ | STT/OCR/ภาพ | 3 | นามรูป |
| 4 | Memory & Knowledge | สัญญา | context/knowledge | 4 | สัญญา |
| 5 | Persona/Profile Manager | สัญญา | โทน/บุคลิก | 5 | อุปาทาน |
| 6 | Reasoner & Planner | สังขาร | วิเคราะห์/วางแผน | 6 | สังขาร |
| 7 | Tool/Action Executor | สังขาร | เรียกเครื่องมือ | 7 | ภพ |
| 8 | Workflow Orchestrator | สังขาร | ลำดับ/retry | 8 | ชาติ |
| 9 | Feedback & Preference | เวทนา | คะแนนดี/แย่ | 9 | เวทนา |
|10 | Safety & Policy Guard | เวทนา+สังขาร | PDPA/Content/RBAC | 10 | ตัณหา |
|11 | Quality & Eval Lab | เวทนา | golden/regression | 11 | วิญญาณ+เวทนา |
|12 | Observability & Cost Ctrl | รูป | metrics/logs/cost | 12 | ชรา–มรณะ |
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

# 5) cycle_diagram.svg
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
  <text x='600' y='70' text-anchor='middle' class='title'>12 Agents ↔ ปฏิจจสมุปบาท</text>
  <text x='600' y='96' text-anchor='middle' class='subtitle'>Scheduler→Perception→Memory→Reasoner→Executor→Orchestrator→Feedback→Safety→Quality→Observability→Scheduler</text>
  <circle cx='600' cy='620' r='480' fill='none' stroke='#ddd' stroke-width='2'/>
  <!-- nodes -->
  <rect class='node' x='520' y='120' width='160' height='70'/><text class='label' x='600' y='145' text-anchor='middle'>Scheduler</text><text class='label' x='600' y='167' text-anchor='middle'>(อวิชชา)</text>
  <rect class='node' x='760' y='170' width='180' height='70'/><text class='label' x='850' y='195' text-anchor='middle'>Perception</text><text class='label' x='850' y='217' text-anchor='middle'>(วิญญาณ)</text>
  <rect class='node' x='930' y='310' width='190' height='70'/><text class='label' x='1025' y='335' text-anchor='middle'>Multimodal</text><text class='label' x='1025' y='357' text-anchor='middle'>(นามรูป)</text>
  <rect class='node' x='1010' y='500' width='170' height='70'/><text class='label' x='1095' y='525' text-anchor='middle'>Memory</text><text class='label' x='1095' y='547' text-anchor='middle'>(สัญญา)</text>
  <rect class='node' x='960' y='700' width='180' height='70'/><text class='label' x='1050' y='725' text-anchor='middle'>Persona</text><text class='label' x='1050' y='747' text-anchor='middle'>(อุปาทาน)</text>
  <rect class='node' x='770' y='850' width='180' height='70'/><text class='label' x='860' y='875' text-anchor='middle'>Reasoner</text><text class='label' x='860' y='897' text-anchor='middle'>(สังขาร)</text>
  <rect class='node' x='520' y='900' width='160' height='70'/><text class='label' x='600' y='925' text-anchor='middle'>Executor</text><text class='label' x='600' y='947' text-anchor='middle'>(ภพ)</text>
  <rect class='node' x='300' y='850' width='180' height='70'/><text class='label' x='390' y='875' text-anchor='middle'>Orchestrator</text><text class='label' x='390' y='897' text-anchor='middle'>(ชาติ)</text>
  <rect class='node' x='130' y='700' width='190' height='70'/><text class='label' x='225' y='725' text-anchor='middle'>Feedback</text><text class='label' x='225' y='747' text-anchor='middle'>(เวทนา)</text>
  <rect class='node' x='60' y='500' width='190' height='70'/><text class='label' x='155' y='525' text-anchor='middle'>Safety</text><text class='label' x='155' y='547' text-anchor='middle'>(ตัณหา)</text>
  <rect class='node' x='80' y='310' width='180' height='70'/><text class='label' x='170' y='335' text-anchor='middle'>Quality</text><text class='label' x='170' y='357' text-anchor='middle'>(ประเมิน)</text>
  <rect class='node' x='280' y='170' width='190' height='70'/><text class='label' x='375' y='195' text-anchor='middle'>Observability</text><text class='label' x='375' y='217' text-anchor='middle'>(ชรา-มรณะ)</text>
  <!-- edges -->
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
# AI Agents Baseline v1 (2025-09-11)
- Design Pack: AI Agents ↔ ขันธ์ห้า ↔ ปฏิจจสมุปบาท
- Files: README.md, roadmap.md, agents_table.md, agents_flow.mmd, cycle_diagram.svg
- Use this as the starting baseline for future iterations.
"@ | Set-Content "$Root\agents_baseline_v1.md" -Encoding UTF8

# 7) ZIP (latest) + ZIP v1 copy
if (Test-Path $ZipLatest) { Remove-Item $ZipLatest -Force }
Compress-Archive -Path "$Root\*" -DestinationPath $ZipLatest
if (Test-Path $ZipV1) { Remove-Item $ZipV1 -Force }
Copy-Item $ZipLatest $ZipV1

# 8) Verify (ASCII-only logs to avoid parsing issues)
$req = @(
  "README.md","roadmap.md","agents_table.md",
  "agents_flow.mmd","cycle_diagram.svg","agents_baseline_v1.md"
)
foreach($f in $req){
  if(Test-Path (Join-Path $Root $f)){
    Say ("FOUND: {0}" -f $f) "Green"
  } else {
    Say ("MISSING: {0}" -f $f) "Red"
  }
}
if(Test-Path $ZipLatest){ Say ("FOUND ZIP: {0}" -f $ZipLatest) "Green" } else { Say ("MISSING ZIP: {0}" -f $ZipLatest) "Red" }
if(Test-Path $ZipV1){ Say ("FOUND ZIP v1: {0}" -f $ZipV1) "Green" } else { Say ("MISSING ZIP v1: {0}" -f $ZipV1) "Red" }

# Keyword sanity checks
if(Select-String -Quiet -Pattern "Roadmap AI Agents" -Path "$Root\roadmap.md"){ Say "roadmap.md keyword OK" "Green" } else { Say "roadmap.md keyword NOT FOUND" "Yellow" }
if(Select-String -Quiet -Pattern "12 AI Agents" -Path "$Root\agents_table.md"){ Say "agents_table.md keyword OK" "Green" } else { Say "agents_table.md keyword NOT FOUND" "Yellow" }
if(Select-String -Quiet -Pattern "flowchart" -Path "$Root\agents_flow.mmd"){ Say "agents_flow.mmd mermaid OK" "Green" } else { Say "agents_flow.mmd mermaid NOT FOUND" "Yellow" }

Say ("DONE. Folder: {0}" -f $Root) "Cyan"
Say ("DONE. Zip:    {0}" -f $ZipLatest) "Cyan"
Say ("DONE. Zip v1: {0}" -f $ZipV1) "Cyan"

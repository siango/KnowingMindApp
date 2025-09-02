<#
.SYNOPSIS
  Import an n8n workflow JSON via CLI (no Docker).

.PARAMETER WorkflowJson
  Full path to the workflow JSON file to import.

.PARAMETER UseNpx
  If set, uses `npx n8n` instead of global `n8n` install.
#>
param(
  [Parameter(Mandatory=$true)]
  [string]$WorkflowJson,
  [switch]$UseNpx
)

function Require-Node {
  try {
    $v = node -v 2>$null
    if (-not $v) { throw "Node.js is not installed." }
    Write-Host "Node.js version: $v"
  } catch {
    Write-Error "ไม่พบ Node.js ในเครื่องนี้ กรุณาติดตั้ง Node.js 18+ ก่อน (https://nodejs.org/)"
    exit 1
  }
}

function Ensure-N8N {
  if ($UseNpx) { return }
  $n8nCmd = Get-Command n8n -ErrorAction SilentlyContinue
  if (-not $n8nCmd) {
    Write-Host "ติดตั้ง n8n แบบ global ด้วย npm..."
    npm install -g n8n
  } else {
    Write-Host "พบ n8n ติดตั้งแล้ว: $($n8nCmd.Source)"
  }
}

function Import-Workflow {
  if ($UseNpx) {
    Write-Host "ใช้ npx n8n import:workflow ..."
    npx n8n import:workflow --input="$WorkflowJson"
  } else {
    Write-Host "ใช้ n8n import:workflow ..."
    n8n import:workflow --input="$WorkflowJson"
  }
}

# --- main ---
Require-Node
Ensure-N8N
if (-not (Test-Path $WorkflowJson)) {
  Write-Error "ไม่พบไฟล์: $WorkflowJson"
  exit 1
}
Import-Workflow
Write-Host "✔ นำเข้าเวิร์กโฟลว์เสร็จแล้ว! เปิด n8n UI ได้ที่ http://localhost:5678 (หลังจากสั่งรัน n8n)"
# === CONFIG ===
$base  = $env:N8N_BASE_URL.TrimEnd("/")
$hdrs  = @{
  "accept"        = "application/json"
  "Content-Type"  = "application/json"
  "X-N8N-API-KEY" = $env:N8N_API_KEY
}

# ❗️อย่าใส่ "active": true ตอนสร้าง
$wfJson = @'
{
  "name": "ArunRoo - Podcast Queue (REV-E quick)",
  "settings": { "timezone": "Asia/Bangkok" },
  "nodes": [
    {
      "parameters": {
        "triggerTimes": { "item": [{ "mode": "everyX", "unit": "minutes", "value": 10 }] }
      },
      "type": "n8n-nodes-base.cron",
      "typeVersion": 1,
      "position": [280, 240],
      "name": "Cron"
    },
    {
      "parameters": {
        "operation": "read",
        "sheetId": "={{$env.ARUNROO_SHEET_ID}}",
        "range": "podcast_queue!A1:Z9999"
      },
      "type": "n8n-nodes-base.googleSheets",
      "typeVersion": 5,
      "position": [520, 240],
      "name": "Read Sheet"
    }
  ],
  "connections": {
    "Cron": { "main": [[{ "node": "Read Sheet", "type": "main", "index": 0 }]] }
  }
}
'@

try {
  # 1) Create
  $create = Invoke-RestMethod -Uri "$base/api/v1/workflows" -Headers $hdrs -Method POST -Body $wfJson
  Write-Host "Created workflow: id=$($create.id) name=$($create.name)" -ForegroundColor Green

  # 2) Try to activate (optional; will fail if credentialsยังไม่ตั้ง)
  try {
    Invoke-RestMethod -Uri "$base/api/v1/workflows/$($create.id)/activate" -Headers $hdrs -Method POST | Out-Null
    Write-Host "Activated workflow: id=$($create.id)" -ForegroundColor Green
  } catch {
    Write-Warning "Activate ไม่สำเร็จ (อาจยังไม่ได้ผูก credentials ใน UI) — workflow ถูกสร้างแล้ว แต่ยัง inactive"
  }

  $create
} catch {
  Write-Error $_.Exception.Message
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
  throw
}

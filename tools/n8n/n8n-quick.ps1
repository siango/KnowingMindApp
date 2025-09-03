# อยู่ที่ tools\n8n\n8n-quick.ps1
# ใช้งาน: .\n8n-quick.ps1 42 -Force

param(
  [int]$EpisodeId = 42,
  [switch]$Force
)

# --- Config ---
$BASE = $env:N8N_BASE_URL
if (-not $BASE) { $BASE = "https://siango.app.n8n.cloud" }
$BASE = $BASE.TrimEnd('/')

$WF = "graLW6JHAIigsoE7"

# --- หาข้อมูล Project + Path ---
$all = Invoke-RestMethod -Uri "$BASE/api/v1/workflows" -Headers @{accept="application/json";"X-N8N-API-KEY"=$env:N8N_API_KEY} -Method GET
$proj = ($all.data | Where-Object { $_.id -eq $WF }).shared[0].projectId

$wf = Invoke-RestMethod -Uri "$BASE/api/v1/workflows/$WF" -Headers @{accept="application/json";"X-N8N-API-KEY"=$env:N8N_API_KEY;"X-N8N-Project"=$proj} -Method GET
$wh = $wf.nodes | Where-Object { $_.type -eq "n8n-nodes-base.webhook" } | Select-Object -First 1

$prod = "$BASE/webhook/$($wh.parameters.path)"

# --- ยิง webhook ---
$payload = @{ episodeId = $EpisodeId; force = [bool]$Force } | ConvertTo-Json
$res = Invoke-RestMethod -Uri $prod -Method POST -Headers @{ "Content-Type"="application/json" } -Body $payload
$res

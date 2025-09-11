Param(
  [string]$Device
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\common\windows_lib.ps1"

if([string]::IsNullOrWhiteSpace($Device)){ Die "ใช้: .\osp_single.ps1 -Device <device_id>" }

$devPath = Join-Path (Join-Path $PSScriptRoot "..\devices") ($Device + ".yaml")
if(-not (Test-Path $devPath)){ Die "ไม่พบไฟล์ $devPath" }

Ensure-Tools
$data = Import-Yaml $devPath

$repoUrl    = $data.repo.url
$repoPath   = $data.repo.path
$repoBranch = $data.repo.branch

Git-Sync $repoUrl $repoPath $repoBranch

# TODO: โหลด secrets จาก GSM (ใช้ secrets_osp.ps1 ที่ส่งให้ก่อนหน้า)
# ตัวอย่าง health-check
try {
  $resp = (curl.exe -sI "https://knowingmindproject.website") -join "`n"
  $status = "✅"
  if(-not $resp){ $status = "⚠" }
  Write-Matrix $Device $status ($resp.Split("`n")[0])
} catch {
  Write-Matrix $Device "❌" "no response"
}
Ok "เสร็จ: $Device"
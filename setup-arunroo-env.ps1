# ================= CONFIG =================
$defaults = @{
  "N8N_BASE_URL"     = "https://siango.app.n8n.cloud"
  "KMA_API_BASE"     = "https://kma-api-knowing-mind-app.asia-southeast1.run.app"
  "ARUNROO_SHEET_ID" = ""
  "N8N_API_KEY"      = ""
}

Write-Host "=== ตรวจสอบและตั้งค่า ENV สำหรับ ArunRoo Podcast Queue ===" -ForegroundColor Cyan

function Ensure-EnvVar([string]$key, [string]$default) {
    $cur = [Environment]::GetEnvironmentVariable($key, "User")

    if ([string]::IsNullOrEmpty($cur)) {
        if ([string]::IsNullOrEmpty($default)) {
            $ok = $false
            while (-not $ok) {
                $inputVal = Read-Host "ใส่ค่า $key"
                if (-not [string]::IsNullOrEmpty($inputVal)) {
                    if ($key -eq "ARUNROO_SHEET_ID") {
                        if ($inputVal -match '^[A-Za-z0-9-_]{20,}$') {
                            [Environment]::SetEnvironmentVariable($key, $inputVal, "User")
                            Write-Host ("✔ ตั้งค่า {0}" -f $key) -ForegroundColor Green
                            $ok = $true
                        } else {
                            Write-Warning "ค่า $key ที่ใส่มาไม่เหมือน Google Sheets ID"
                        }
                    } else {
                        [Environment]::SetEnvironmentVariable($key, $inputVal, "User")
                        Write-Host ("✔ ตั้งค่า {0}" -f $key) -ForegroundColor Green
                        $ok = $true
                    }
                } else {
                    Write-Warning ("{0} ยังว่างอยู่ ต้องตั้งค่าก่อนใช้งานจริง!" -f $key)
                }
            }
        } else {
            [Environment]::SetEnvironmentVariable($key, $default, "User")
            Write-Host ("✔ ตั้งค่า {0} = {1}" -f $key, $default) -ForegroundColor Green
        }
    } else {
        if ($key -eq "ARUNROO_SHEET_ID" -and $cur -notmatch '^[A-Za-z0-9-_]{20,}$') {
            Write-Warning "$key ที่บันทึกไว้ดูไม่เหมือน Google Sheet ID (ค่าเดิม: $cur)"
            $newVal = Read-Host "กรอกค่า $key ใหม่ (จาก URL Google Sheets)"
            if ($newVal -match '^[A-Za-z0-9-_]{20,}$') {
                [Environment]::SetEnvironmentVariable($key, $newVal, "User")
                $cur = $newVal
                Write-Host "✔ ปรับปรุง $key แล้ว" -ForegroundColor Green
            } else {
                Write-Warning "ยังไม่ใช่ค่า ID ที่ถูกต้อง กรุณาแก้ไขภายหลัง!"
            }
        }
        Write-Host ("✔ พบ {0} อยู่แล้ว = {1}" -f $key, $cur) -ForegroundColor Yellow
    }
}

foreach ($k in $defaults.Keys) {
    Ensure-EnvVar $k $defaults[$k]
}

$env:N8N_BASE_URL     = [Environment]::GetEnvironmentVariable("N8N_BASE_URL", "User")
$env:N8N_API_KEY      = [Environment]::GetEnvironmentVariable("N8N_API_KEY", "User")
$env:ARUNROO_SHEET_ID = [Environment]::GetEnvironmentVariable("ARUNROO_SHEET_ID", "User")
$env:KMA_API_BASE     = [Environment]::GetEnvironmentVariable("KMA_API_BASE", "User")

Write-Host "`n=== ค่า ENV ปัจจุบัน ===" -ForegroundColor Cyan
Write-Host ("N8N_BASE_URL     = {0}" -f $env:N8N_BASE_URL)
Write-Host ("N8N_API_KEY      = {0}" -f (if ($env:N8N_API_KEY) { "<SET>" } else { "<EMPTY>" }))
Write-Host ("ARUNROO_SHEET_ID = {0}" -f (if ($env:ARUNROO_SHEET_ID) { $env:ARUNROO_SHEET_ID } else { "<EMPTY>" }))
Write-Host ("KMA_API_BASE     = {0}" -f $env:KMA_API_BASE)
Write-Host "=============================================" -ForegroundColor Cyan

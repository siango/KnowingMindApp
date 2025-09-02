<# 
  setup-healthcheck.ps1
  Purpose: Enable APIs, bind IAM, and create/update a Cloud Scheduler health-check job for a Cloud Run service.
  Default project: knowing-mind-app
  Default region/location: asia-southeast1
#>

param(
  [string]$Project = "knowing-mind-app",
  [string]$Region = "asia-southeast1",          # Cloud Run region
  [string]$Location = "asia-southeast1",        # Cloud Scheduler location (usually same as Region)
  [string]$Service = "satishift-fullstack",     # Cloud Run service name
  [string]$JobName = "satishift-fullstack-health",
  [string]$ServiceAccount = "svc-runtime@knowing-mind-app.iam.gserviceaccount.com",
  [string]$Cron = "*/5 * * * *"                 # Every 5 minutes
)

function Info($m){ Write-Host "• $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "✓ $m" -ForegroundColor Green }
function Warn($m){ Write-Host "! $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "✗ $m" -ForegroundColor Red }

# --- Preflight: gcloud available ---
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
  Err "ไม่พบ gcloud ใน PATH — ติดตั้ง Google Cloud SDK ก่อนครับ"
  exit 1
}

# --- Auth & Config ---
Info "ตั้งค่าโปรเจกต์ $Project และรีเจียน $Region"
& gcloud config set project $Project | Out-Null
& gcloud config set run/region $Region | Out-Null

$acct = (& gcloud auth list --filter=status:ACTIVE --format="value(account)")
if (-not $acct) {
  Warn "ยังไม่ได้ล็อกอิน gcloud"
  & gcloud auth login
  $acct = (& gcloud auth list --filter=status:ACTIVE --format="value(account)")
}
Ok "บัญชีที่ใช้: $acct"

# --- Enable required APIs ---
$apis = @(
  "cloudscheduler.googleapis.com",
  "iamcredentials.googleapis.com"
)
Info "เปิดใช้ API ที่จำเป็น: $($apis -join ', ')"
& gcloud services enable $apis --project $Project
if ($LASTEXITCODE -ne 0) {
  Err "เปิด API ไม่สำเร็จ — ตรวจสิทธิ์บัญชี (ต้องมีสิทธิ์ Owner/Editor หรือ Service Usage Admin)"
  exit 1
}
Ok "เปิด API เรียบร้อย"

# --- Resolve Cloud Run URL ---
Info "อ่าน Service URL ของ Cloud Run: $Service"
$Url = (& gcloud run services describe $Service --region $Region --format="value(status.url)")
if (-not $Url) {
  Err "ไม่พบ Cloud Run service: $Service ใน $Region"
  exit 1
}
Ok "Service URL: $Url"

# --- Ensure run.invoker for the service account ---
Info "ให้สิทธิ์ run.invoker แก่ $ServiceAccount"
& gcloud run services add-iam-policy-binding $Service `
  --region=$Region `
  --member="serviceAccount:$ServiceAccount" `
  --role="roles/run.invoker" | Out-Null
Ok "ผูกสิทธิ์เรียบร้อย"

# --- Create or Update Scheduler Job ---
Info "สร้าง/อัปเดต Cloud Scheduler job: $JobName ($Location)"
# Check if job exists
& gcloud scheduler jobs describe $JobName --location=$Location --format="value(name)" 2>$null | Out-Null
$exists = ($LASTEXITCODE -eq 0)

if ($exists) {
  Info "พบงานเดิม → update"
  & gcloud scheduler jobs update http $JobName `
    --location=$Location `
    --schedule="$Cron" `
    --uri="$Url/health" `
    --http-method=GET `
    --oidc-service-account-email="$ServiceAccount" `
    --oidc-token-audience="$Url" | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Err "อัปเดตงานไม่สำเร็จ"
    exit 1
  }
  Ok "อัปเดตงานเรียบร้อย"
} else {
  Info "ไม่พบงานเดิม → create"
  & gcloud scheduler jobs create http $JobName `
    --location=$Location `
    --schedule="$Cron" `
    --uri="$Url/health" `
    --http-method=GET `
    --oidc-service-account-email="$ServiceAccount" `
    --oidc-token-audience="$Url" | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Err "สร้างงานไม่สำเร็จ"
    exit 1
  }
  Ok "สร้างงานเรียบร้อย"
}

# --- Dry run once ---
Info "ทดสอบรันทันที 1 ครั้ง"
& gcloud scheduler jobs run $JobName --location=$Location | Out-Null
if ($LASTEXITCODE -ne 0) {
  Warn "สั่ง run job มีข้อผิดพลาด — ตรวจ logs เสริม"
} else {
  Ok "สั่ง run job สำเร็จ"
}

# --- Show summary ---
Write-Host ""
Ok "สรุปสถานะ"
& gcloud scheduler jobs describe $JobName --location=$Location
Write-Host ""
Ok "รายการงานใน $Location"
& gcloud scheduler jobs list --location=$Location

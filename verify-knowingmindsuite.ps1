function P($m){ Write-Host "[PASS] $m" -ForegroundColor Green }
function F($m){ Write-Host "[FAIL] $m" -ForegroundColor Red }
function I($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }

$Proj="knowing-mind-app"; $Reg="asia-southeast1"

I "gcloud --version"; try { gcloud --version | Write-Host } catch { F "gcloud not found"; exit 1 }

$Icur = gcloud config list --format="value(core.project,run.region)"
if ($Icur -match "^$Proj\s+$Reg$") { P "project/region OK: $Icur" } else { F "config mismatch: $Icur"; I "set: gcloud config set project $Proj; gcloud config set run/region $Reg" }

$need = @('run.googleapis.com','artifactregistry.googleapis.com','containerregistry.googleapis.com','secretmanager.googleapis.com','cloudbuild.googleapis.com','workflows.googleapis.com','cloudscheduler.googleapis.com','pubsub.googleapis.com','firestore.googleapis.com')
$enabled = gcloud services list --enabled --format="value(config.name)"
foreach($s in $need){ if ($enabled -match "^$s$") { P "API enabled: $s" } else { F "API missing: $s" } }

I "Cloud Run services"
$svc = gcloud run services list --platform=managed --region=$Reg --format="value(metadata.name)"
foreach($name in @('arunroo-ics','satishift-webhook','kma-api')){ if ($svc -match "^$name$") { P "Found: $name" } else { F "Missing: $name" } }

I "Describe kma-api"
try { gcloud run services describe kma-api --region=$Reg --format="table(metadata.name,status.url)" | Write-Host } catch { I "kma-api describe skipped." }

Write-Host "Done." -ForegroundColor Yellow

param(
  [string]$Location = "asia-southeast1",
  [string]$TimeZone = "Asia/Bangkok"
)

$jobs = & gcloud scheduler jobs list --location=$Location --format="value(name)"
if(!$jobs){ Write-Host "No jobs found in $Location"; exit 0 }

$jobs | ForEach-Object {
  $name = $_.Trim()
  if($name){
    Write-Host "Updating $name → $TimeZone"
    & gcloud scheduler jobs update http $name --location=$Location --time-zone=$TimeZone 2>$null
  }
}
Write-Host "Done."

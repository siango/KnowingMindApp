[CmdletBinding()]
param(
  [string[]]$Services=@("arunroo-ics","satishift-webhook","kma-api"),
  [int]$TimeoutSec=10
)
$BaseUrl=@{
  "arunroo-ics"="https://arunroo-ics-610232224779.asia-southeast1.run.app";
  "satishift-webhook"="https://satishift-webhook-610232224779.asia-southeast1.run.app";
  "kma-api"="https://kma-api-610232224779.asia-southeast1.run.app";
}
$Paths=@("/","/api/ping","/health")
foreach($svc in $Services){
  if(-not $BaseUrl.ContainsKey($svc)){ Write-Host "[skip] $svc no base url"; continue }
  $base=$BaseUrl[$svc]
  Write-Host "== $svc ($base)"
  foreach($p in $Paths){
    $url="$base$p"
    try{
      $r=Invoke-WebRequest -Uri $url -Method GET -TimeoutSec $TimeoutSec
      Write-Host "$url -> $($r.StatusCode)"
    } catch {
      Write-Host "$url -> FAILED: $($_.Exception.Message)"
    }
  }
  ""
}

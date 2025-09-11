function Ensure-Choco($pkg){
  if(-not (Get-Command $pkg -ErrorAction SilentlyContinue)){
    choco install $pkg -y | Out-Null
  }
}
function Git-Sync($repo,$branch,$path){
  if(Test-Path (Join-Path $path ".git")){
    Push-Location $path; git fetch; git reset --hard origin/$branch; Pop-Location
  } else {
    git clone -b $branch $repo $path
  }
}
function Get-Secret($Key){
  & $env:USERPROFILE\.secrets_toolkit\get_secret.ps1 $Key
}
function Health-Check($Url){
  try { (Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10).StatusCode } catch { "FAIL" }
}

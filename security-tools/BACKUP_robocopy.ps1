# Daily backup of project-docs to another location
param(
  [string]$Source = ".\project-docs",
  [string]$Dest = "D:\KM_Backup\project-docs"
)

if(!(Test-Path $Source)){ Write-Error "Source not found: $Source"; exit 1 }
if(!(Test-Path $Dest)){ New-Item -ItemType Directory -Force -Path $Dest | Out-Null }

# /MIR mirrors directory, /R:2 retry twice, /W:2 wait 2s
robocopy $Source $Dest /MIR /R:2 /W:2 /NFL /NDL /NP
if($LASTEXITCODE -le 3){
  Write-Host "Backup finished." -ForegroundColor Green
}else{
  Write-Warning "Robocopy returned code $LASTEXITCODE"
}

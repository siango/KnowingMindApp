[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Source,
  [Parameter(Mandatory=$true)][string]$Dest
)
if(!(Test-Path $Source)){ throw "Source not found: $Source" }
if(!(Test-Path $Dest)){ New-Item -ItemType Directory -Path $Dest | Out-Null }
robocopy $Source $Dest /MIR /R:2 /W:2 /XD ".git" "node_modules" ".gradle" ".idea" "build" "dist" /XF "*.tmp" "*.log"
if($LASTEXITCODE -ge 8){ throw "Robocopy failed with code $LASTEXITCODE" }

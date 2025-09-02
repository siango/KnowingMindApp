param(
  [string]$Source = ".",
  [string]$Destination = "D:\Backup\KnowingMindSuite"
)

$cmd = "robocopy `"$Source`" `"$Destination`" /MIR /Z /FFT /R:3 /W:5 /XD .git out node_modules"
Write-Host "Running: $cmd"
Invoke-Expression $cmd

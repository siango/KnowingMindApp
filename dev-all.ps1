# dev-all.ps1
$root = "C:\AndroidProjects\KnowingMindSuite"

Start-Process pwsh -ArgumentList "-NoExit","-Command","cd $root\services\arunroo-ics; pnpm run dev"
Start-Process pwsh -ArgumentList "-NoExit","-Command","cd $root\services\satishift-webhook; pnpm run dev"
Start-Process pwsh -ArgumentList "-NoExit","-Command","cd $root\services\kma-api; pnpm run dev"

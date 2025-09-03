
Param([string]$EnvFile = "tools\n8n\.env")
$N8N_BASE_URL = Read-Host "N8N_BASE_URL (เช่น https://siango.app.n8n.cloud - ไม่ต้องมี / ท้าย)"
$N8N_BASE_URL = $N8N_BASE_URL.TrimEnd("/")
$N8N_API_KEY = Read-Host "N8N_API_KEY (วางคีย์ที่สร้างใน n8n)"
$N8N_BASIC_AUTH_USER = Read-Host "N8N_BASIC_AUTH_USER (เว้นว่างได้)"
$N8N_BASIC_AUTH_PASSWORD = Read-Host "N8N_BASIC_AUTH_PASSWORD (เว้นว่างได้)"
Set-Content -Path $EnvFile -Value @"
N8N_BASE_URL=$N8N_BASE_URL
N8N_API_KEY=$N8N_API_KEY
N8N_BASIC_AUTH_USER=$N8N_BASIC_AUTH_USER
N8N_BASIC_AUTH_PASSWORD=$N8N_BASIC_AUTH_PASSWORD
"@
Write-Host "✅ เขียนไฟล์ $EnvFile เรียบร้อย"

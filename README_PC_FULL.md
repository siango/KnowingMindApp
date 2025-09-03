
# KnowingMindSuite – PC Tools (Windows/PowerShell) – FULL

## Quick Start
```powershell
cd .\tools\n8n\
powershell -ExecutionPolicy Bypass -File .\secrets_bootstrap.ps1
powershell -ExecutionPolicy Bypass -File .\secrets_print.ps1
powershell -ExecutionPolicy Bypass -File .\n8n_test.ps1
```

## List, Trigger, Health
```powershell
# List all (or search)
powershell -ExecutionPolicy Bypass -File .\n8n_list.ps1
powershell -ExecutionPolicy Bypass -File .\n8n_list.ps1 -Search "ArunRoo"

# Trigger by name or id (+ optional payload)
powershell -ExecutionPolicy Bypass -File .\n8n_trigger.ps1 -Name "ArunRoo"
powershell -ExecutionPolicy Bypass -File .\n8n_trigger.ps1 -Id graLW6JHAIigsoE7 -PayloadJson '{ "episodeId": 42 }'
powershell -ExecutionPolicy Bypass -File .\n8n_trigger.ps1 -Name "ArunRoo" -PayloadFile ..\..\payloads\sample.json

# Check health
powershell -ExecutionPolicy Bypass -File .\n8n_health.ps1

# Decode token expiry
powershell -ExecutionPolicy Bypass -File .\token_expiry.ps1
```

## Export / Import
```powershell
# Export by id or name
powershell -ExecutionPolicy Bypass -File .\n8n_export.ps1 -Id graLW6JHAIigsoE7 -OutFile ..\..\payloads\arunroo_export.json
powershell -ExecutionPolicy Bypass -File .\n8n_export.ps1 -Name "ArunRoo" -OutFile ..\..\payloads\arunroo_export.json

# Import as new
powershell -ExecutionPolicy Bypass -File .\n8n_import.ps1 -File ..\..\payloads\arunroo_export.json

# Import & update if 'id' exists
powershell -ExecutionPolicy Bypass -File .\n8n_import.ps1 -File ..\..\payloads\arunroo_export.json -UpdateIfExists
```

## Notes
- หลีกเลี่ยง commit ไฟล์ `.env` ลง Git
- จำเป็นต้องเปิด Public API ใน n8n หรือใช้ Basic Auth ร่วมกัน
- บาง self-host อาจมี endpoint ต่างจากนี้ โปรดปรับตามเอกสารเวอร์ชัน instance

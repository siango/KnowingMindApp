# Make Gateway (CLI/API)

ใช้สั่งงาน Make โดยไม่ต้องเข้า UI กราฟฟิก

## PowerShell (Windows)
```powershell
# webhook (ยิงงานครั้งเดียว)
.\make_gateway.ps1 -Mode webhook -WebhookUrl "https://hook.us1.make.com/xxxx" -JsonData '{"command":"publish"}'

# เปิด/ปิด scenario
.\make_gateway.ps1 -Mode start -ApiKey "YOUR_API_KEY" -ScenarioId 123456
.\make_gateway.ps1 -Mode stop -ApiKey "YOUR_API_KEY" -ScenarioId 123456

# run ครั้งเดียว (รอผล)
.\make_gateway.ps1 -Mode run -ApiKey "YOUR_API_KEY" -ScenarioId 123456 -JsonData '{"responsive":true,"data":{"caption":"โพสต์เดี๋ยวนี้"}}'
```

## Bash (Linux/Cloud Run)
```bash
export API_KEY="YOUR_API_KEY"; export SCENARIO_ID=123456
./make_gateway.sh run
```

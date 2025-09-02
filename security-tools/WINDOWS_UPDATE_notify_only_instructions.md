# Windows Update: Notify Only (No Auto Download/Install)

**Windows 11/10 Pro/Enterprise**

1. กด `Win + R` พิมพ์ `gpedit.msc`
2. ไปที่: `Computer Configuration → Administrative Templates → Windows Components → Windows Update → Manage end user experience`
3. เปิดนโยบาย **Configure Automatic Updates** เป็น **Enabled**
4. เลือกตัวเลือก **2 - Notify for download and auto install**
5. Apply → OK
6. รีสตาร์ทเครื่องเมื่อสะดวก

**หมายเหตุ:** ถ้าต้องการหยุดชั่วคราวแบบแรง ให้เปิด `services.msc` → `Windows Update` → Startup type = `Disabled` (ไม่แนะนำระยะยาว)

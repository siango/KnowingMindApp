# Security Tools Pack

- `CHECKSUM_baseline.ps1` → สร้างเช็คซัม SHA256 baseline
- `CHECKSUM_verify.ps1` → ตรวจเทียบกับ baseline (รู้ทันทีถ้ามีไฟล์ถูกแก้)
- `BACKUP_robocopy.ps1` → สำรองโฟลเดอร์ `project-docs` รายวัน
- `WINDOWS_UPDATE_notify_only_instructions.md` → ตั้ง Windows Update ให้แจ้งก่อนเสมอ
- `README_SECURITY.md` → เอกสารนี้

เวิร์กโฟลว์แนะนำ:
1. รัน `CHECKSUM_baseline.ps1` ครั้งแรกหลังวางไฟล์
2. ทุกครั้งก่อนส่ง/ก่อนเปลี่ยนมือ รัน `CHECKSUM_verify.ps1`
3. ตั้ง Task Scheduler ให้รัน `BACKUP_robocopy.ps1` ทุกคืน

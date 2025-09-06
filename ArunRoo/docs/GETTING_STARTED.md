# Getting Started

## ความต้องการ
- **Docker** 24+ (แนะนำสำหรับ n8n)
- **Node.js** 18 LTS+ (หากต้องรัน n8n แบบ npm)
- **Python** 3.10+ (ใช้กับสคริปต์ช่วยงานบางส่วน)

## ขั้นตอนเร็ว
1. โคลนรีโปแล้วตรวจสอบโครงสร้างโฟลเดอร์
2. ตั้งค่า n8n ด้วย `n8n/docker-compose.yml` → `docker compose up -d`
3. อิมพอร์ตเวิร์กโฟลว์ (กำลังจัดเตรียม) แล้วตั้งค่า Credentials โซเชียล
4. เตรียมไฟล์คำคมจาก `templates/quotes_template.csv` → วางใน `content/quotes/YYYY-MM`
5. รันทดสอบ Monthly Setup แล้วปล่อย Daily Publisher ทำงานอัตโนมัติ

## โครงสร้างไฟล์ (ย่อ)
- `docs/ARCHITECTURE.md` สถาปัตยกรรมและข้อมูลเชิงระบบ
- `docs/WORKFLOW_N8N.md` ขั้นตอนและโหนดหลักใน n8n
- `docs/CONTENT_STANDARDS.md` มาตรฐานภาพ โลโก้ ข้อความ แฮชแท็ก
- `docs/DIRECTORY_STRUCTURE.md` ผังโฟลเดอร์และเหตุผล

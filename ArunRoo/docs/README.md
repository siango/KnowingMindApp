# อรุณรู้ (ArunRoo) – Starter Kit

แอพ/ระบบสำหรับสร้าง–จัดคิว–เผยแพร่ **คำคม/คำทักทายยามเช้า** ไปยัง Facebook, Instagram, YouTube และ TikTok ล่วงหน้า 30 วัน
จัดทำสำหรับโปรเจกต์ **infographic daily** และเผื่อขยายไปยังโซเชียลอื่นในอนาคต

## โครงสร้างโฟลเดอร์
ดูและแก้ไขได้ในโฟลเดอร์ย่อย ต่อไปนี้เป็นสรุป
- `brand/` โลโก้ “ป่าโนนนิเวศน์” และพาเลตสี
- `content/` แหล่งข้อมูลต้นทาง (quotes, greetings, captions)
- `prompts/` prompt สำหรับ image/video
- `assets/` ไฟล์ภาพ/วิดีโอที่สร้างแล้ว (final)
- `schedules/` ปฏิทิน/กำหนดการ 30 วัน
- `automation/` เวิร์กโฟลว์ n8n และสคริปต์โพสต์
- `outputs/` สรุปผล/รายงาน
- `docs/` เอกสารประกอบ

## เวิร์กโฟลว์แนะนำ (n8n)
- **ArunRoo – Daily Publisher (Cron 5 นาที)**: อ่านไฟล์ `outputs/postmap_*.csv` แล้วโพสต์รายการที่ถึงเวลา
- **ArunRoo – Monthly Setup (Manual/Cron)**: เตรียมคิว 30 วันล่วงหน้าจากไฟล์ Excel/CSV

> ดูโฟลเดอร์ `automation/n8n/` มีตัวอย่างเวิร์กโฟลว์ (`*.json`) สำหรับ import เข้า n8n

## การตั้งค่าโทเคน
คัดลอก `.env.example` เป็น `.env` แล้วเติมค่าจริง (ห้าม commit โค้ดส่วนนี้ขึ้น repo สาธารณะ)

## ช่วงเวลามาตรฐาน (แก้ไขได้)
- Facebook Page: 07:30
- Instagram: 07:35
- YouTube (Shorts หรือคลิปสั้น): 07:45
- TikTok: 07:50

โซนเวลา: Asia/Bangkok

## ขั้นตอนสั้น ๆ
1. เติม/แก้ไขข้อมูลที่ `content/quotes/2025-08/*.xlsx` และ `content/greetings/` (ถ้ามี)
2. สร้างภาพ/วิดีโอด้วยสคริปต์ใน `automation/scripts/` หรือเครื่องมือของคุณ แล้ววางที่ `assets/`
3. ตรวจ/แก้ไขตาราง `outputs/postmap_YYYY-MM.csv`
4. Import เวิร์กโฟลว์ใน n8n จาก `automation/n8n/*.json`
5. เติมโทเคนใน `.env`
6. เปิดใช้งานเวิร์กโฟลว์ Daily Publisher

## ขยายไปโซเชียลอื่น
เตรียมเทมเพลตสคริปต์ `publish_generic.py` และ n8n snippet ไว้รองรับเพิ่มเติม

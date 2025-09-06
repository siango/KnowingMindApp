# ARCHITECTURE

## ภาพรวม
- แหล่งข้อมูล: ไฟล์ตารางคำคม (CSV/XLSX) → `content/quotes/YYYY-MM`
- ตัวสร้างสื่อ: สคริปต์/โหนดสำหรับวาดภาพ + วิดีโอ (ภายนอก/ภายใน)
- ออโตโพสต์: n8n เชื่อม Social APIs/Connectors (Facebook, Instagram, YouTube, TikTok)
- การเก็บผลลัพธ์: เก็บลิงก์/สถิติ/ไฟล์ลง `outputs/` และบันทึกสรุป

## ข้อมูลสำคัญ
- Asia/Bangkok เป็น Timezone อ้างอิง
- เวิร์กโฟลว์ Monthly Setup สร้างงานล่วงหน้า ส่วน Daily Publisher ยิงงานตามเวลา

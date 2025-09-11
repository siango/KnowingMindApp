# One‑Shot Multi‑Device Toolkit (Termux + Windows)
วันที่: 2025‑09‑11

โครงพร้อมใช้สำหรับรัน one‑shot ตั้งเครื่องหลายเครื่องแบบรวมศูนย์
- ระบุรายละเอียดเครื่องใน `one-shot/devices/*.yaml`
- ใช้ `termux/ost_multi.sh` หรือ `windows/osp_multi.ps1` เพื่อรันพร้อมกันหลายเครื่อง
- ใช้ `*_single` เพื่อดีบักเฉพาะเครื่องเดียว
- ผลตรวจรวมจะบันทึกใน `one-shot/checks/health_matrix.md`

> ต้องติดตั้ง Secrets Toolkit ก่อน (ที่ส่งให้แล้ว: SOPS/age + GSM sync) เพื่อเรียกคีย์ด้วย `~/.secrets_toolkit/get_secret.sh` หรือผ่าน GSM บน Windows

## Quick start (Termux)
```bash
cd one-shot/termux
bash ost_multi.sh --all
# หรือเจาะจงเครื่อง
bash ost_single.sh --device mshorse
```

## Quick start (Windows PowerShell)
```powershell
cd .\one-shot\windows
.\osp_multi.ps1 -All
# หรือเจาะจงเครื่อง
.\osp_single.ps1 -Device oppo-a5
```

## โครงสร้าง
```
one-shot/
  devices/                # โปรไฟล์เครื่อง (YAML)
  common/
    termux_lib.sh
    windows_lib.ps1
  termux/
    ost_multi.sh
    ost_single.sh
  windows/
    osp_multi.ps1
    osp_single.ps1
  checks/
    health_matrix.md
```
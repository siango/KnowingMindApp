# D0 Kickoff Checklist — 2025-08-27 (Asia/Bangkok)

## 1) โครงสร้าง & ไฟล์สำคัญ
- [ ] media/images/ (มี Infographic_Taru_TH.png, Infographic_Taru_TH_EN.png)
- [ ] content/ (มี LPKhem_Media_Starter_Kit_2025-08-26.zip)
- [ ] calendar/ (มี Unified_SprintPlan_2025-08-27_withRetro.ics)
- [ ] docs/ (มี Book_Full_Master_v14_withAppendix_Taru.docx)
- [ ] .github/workflows/android-ci.yml (Android CI)

## 2) CI & Build
- [ ] GitHub Actions แสดง workflow "Android CI"
- [ ] push ล่าสุดทำงานสำเร็จ (เขียว)
- [ ] ./gradlew clean assembleDebug รันผ่านในเครื่อง

## 3) Git Hygiene
- [ ] .gitignore มี: .idea/, .vscode/, *.iml, local.properties, /build, /.gradle
- [ ] ไม่ track ไฟล์เฉพาะเครื่อง: .idea/*, local.properties
- [ ] commit message วันนี้สื่อความชัดเจน
- [ ] (ตัวเลือก) สร้าง tag v0.1.0-P0-setup

## 4) ผลลัพธ์วันนี้ (สรุปย่อ)
- โมดูล/โครงสร้างพร้อมเริ่ม P1
- media/content/calendar/docs พร้อม
- CI ทำงานอัตโนมัติเมื่อมี push/pull request

## 5) Next (พรุ่งนี้)
- P1 Library: Reader (text) + UI รายการ + Theme
- Catalog: data source (whitelist) + download indicator
- Chanting: JSON importer + bookmark

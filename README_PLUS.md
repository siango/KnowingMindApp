# PLUS Pack — Security, Smoke Tests & Safe Cleanup

## Security Tools
- security-tools/CHECKSUM_baseline.ps1
- security-tools/CHECKSUM_verify.ps1
- security-tools/BACKUP_robocopy.ps1
- security-tools/WINDOWS_UPDATE_notify_only_instructions.md

## Cloud Run Smoke Tests
- scripts/cloudrun-smoketest.ps1
- scripts/cloudrun-smoketest.sh

## Safe Cleanup (Windows + Linux/Termux)
- scripts/safe-clean.ps1
- scripts/safe-clean.sh

### Usage quick notes
- Windows (PowerShell):
  - สร้าง baseline: `.\security-tools\CHECKSUM_baseline.ps1 -Root .`
  - ตรวจไฟล์: `.\security-tools\CHECKSUM_verify.ps1 -Root .`
  - Smoke test: `.\scripts\cloudrun-smoketest.ps1`
  - เคลียร์ไฟล์แบบ Dry-Run: `.\scripts\safe-clean.ps1 -Path . -DaysOld 30`
  - ลบจริง: `.\scripts\safe-clean.ps1 -Path . -DaysOld 30 -IncludeNodeModules -Execute`
- Linux/Termux:
  - Smoke test: `bash scripts/cloudrun-smoketest.sh`
  - เคลียร์ไฟล์ Dry-Run: `bash scripts/safe-clean.sh . 30 false`
  - ลบจริง: `bash scripts/safe-clean.sh . 30 true`

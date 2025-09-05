# Windows Update — Notify Only
แนะนำให้ตั้ง Group Policy/Registry เป็นโหมด "Notify" เพื่อหลีกเลี่ยงการรีสตาร์ทกลางงาน
* วิธี GPO: Computer Configuration → Admin Templates → Windows Components → Windows Update → Configure Automatic Updates = 2
* วิธี Registry (ต้องรันใน PowerShell/Admin):
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
  New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -PropertyType DWord -Value 2 -Force | Out-Null

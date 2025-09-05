PowerShell scripts re-issued in ASCII with CRLF to avoid encoding issues.
If you still see 'not digitally signed', run:
  Get-ChildItem -Recurse -File *.ps1 | Unblock-File
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

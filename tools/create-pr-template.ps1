New-Item -ItemType Directory -Force .github | Out-Null
@"
# Pull Request

## 📌 Summary
<!-- อธิบายสั้น ๆ ว่า PR นี้ทำอะไร -->

- Enforce LF across repo (`.gitattributes` + renormalize)
- Drop Git LFS rule for `*.mp3` (store audio externally)
- Normalize EOL after LFS removal
- Add/Update project docs + reminders (`sync-docs.ps1` flow)
- Ignore local media (`media/**`, `assets/audio/**`) and build artifacts (`out/`)
- Add helper scripts (`git-wip.ps1`, `sync-docs.ps1`, `set-scheduler-timezone.ps1`)
- Autoload `pw` / `rw` aliases for fast WIP snapshot/resume
- Cloud Scheduler job `satishift-fullstack-health` timezone set to `Asia/Bangkok`

---

## 📝 Ops Notes
- CI/Dev no longer requires Git LFS  
- If CRLF/LF warnings reappear, run:
  ```bash
  git add --renormalize .
  git commit -m "chore(repo): renormalize"

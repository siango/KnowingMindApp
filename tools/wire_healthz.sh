#!/usr/bin/env bash
set -euo pipefail
SERVS="gateway identity journal ledger donation analytics moderation"
for s in $SERVS; do
  SVC_DIR="services/$s"
  SRV="$SVC_DIR/server.js"
  HLZ="$SVC_DIR/src/healthz.js"

  # ถ้าไม่มี server.js -> สร้าง Express server เบาๆ
  if [ ! -f "$SRV" ]; then
    cat > "$SRV" <<JS
const express = require('express');
const app = express();
const healthz = require('./src/healthz');
healthz(app, '$s');
const port = process.env.PORT || 3000;
app.listen(port, () => console.log('[$s] listening on ' + port));
JS
  else
    # ถ้ามี server.js แล้ว แต่ายังไม่เรียก healthz -> สอดบรรทัดเข้าไป
    grep -q "src/healthz" "$SRV" || awk '
      BEGIN {added=0}
      /express\(\)/ && added==0 {
        print;
        print "const healthz = require(\"./src/healthz\"); healthz(app, \"" ENVIRON["SVC_NAME"] "\");";
        added=1; next
      }
      {print}
    ' SVC_NAME="$s" "$SRV" > "$SRV.tmp" && mv "$SRV.tmp" "$SRV"
  fi

  # ใส่ dev script: npm run dev
  if [ -f "$SVC_DIR/package.json" ]; then
    node - <<'NODE' "$SVC_DIR/package.json"
const fs=require('fs'); const p=process.argv[1];
const pkg=JSON.parse(fs.readFileSync(p,'utf8'));
pkg.scripts = pkg.scripts || {};
if (!pkg.scripts.dev) pkg.scripts.dev = "node server.js";
fs.writeFileSync(p, JSON.stringify(pkg,null,2));
NODE
  else
    cat > "$SVC_DIR/package.json" <<JSON
{
  "name": "$s",
  "version": "0.1.0",
  "private": true,
  "scripts": { "dev": "node server.js" },
  "dependencies": { "express": "^4.19.2" }
}
JSON
  fi
done

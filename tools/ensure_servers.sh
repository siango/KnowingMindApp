#!/usr/bin/env bash
set -euo pipefail

declare -A PORTS=(
  [gateway]=3100
  [identity]=3101
  [journal]=3102
  [ledger]=3103
  [donation]=3104
  [analytics]=3105
  [moderation]=3106
)

SERVS="gateway identity journal ledger donation analytics moderation"

for s in $SERVS; do
  SVC_DIR="services/$s"
  mkdir -p "$SVC_DIR/src"
  # healthz.js (ทับได้ปลอดภัย)
  cat > "$SVC_DIR/src/healthz.js" <<JS
module.exports = function healthz(app, serviceName='${s}') {
  app.get('/healthz', (req, res) => {
    res.status(200).json({ ok: true, service: serviceName, ts: Date.now() });
  });
};
JS

  # server.js (ถ้าไม่มีให้สร้าง, ถ้ามีจะเติมบรรทัด healthz ถ้ายังไม่ถูกเรียก)
  SRV="$SVC_DIR/server.js"
  if [ ! -f "$SRV" ]; then
    cat > "$SRV" <<JS
const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, '${s}');

const port = process.env.PORT || ${PORTS[$s]};
app.listen(port, () => console.log('[${s}] listening on ' + port));
JS
  else
    # แทรกเรียก healthz ถ้ายังไม่มี
    grep -q "src/healthz" "$SRV" || awk -v svc="$s" '
      BEGIN {done=0}
      {print}
      /const app = express\(\);/ && !done {
        print "const healthz = require(\"./src/healthz\");";
        print "healthz(app, \"" svc "\");";
        done=1
      }
    ' "$SRV" > "$SRV.tmp" && mv "$SRV.tmp" "$SRV"

    # ตั้งค่า default port ถ้าไม่มี
    grep -q "process.env.PORT" "$SRV" || awk -v svc="$s" -v p="${PORTS[$s]}" '
      /app\.listen\(/ { found=1 }
      { print }
      END {
        if (!found) {
          print "";
          print "const port = process.env.PORT || " p ";";
          print "app.listen(port, () => console.log(\"[\"+\"" svc "\"+\"] listening on \" + port));";
        }
      }
    ' "$SRV" > "$SRV.tmp" && mv "$SRV.tmp" "$SRV"
  fi

  # package.json: ใส่ dev script / express dep ถ้าจำเป็น
  PKG="$SVC_DIR/package.json"
  if [ -f "$PKG" ]; then
    node -e "const fs=require('fs'),p=process.env.PKG;const pkg=JSON.parse(fs.readFileSync(p,'utf8'));pkg.scripts=pkg.scripts||{};if(!pkg.scripts.dev)pkg.scripts.dev='node server.js';fs.writeFileSync(p,JSON.stringify(pkg,null,2));" PKG="$PKG"
  else
    cat > "$PKG" <<JSON
{
  "name": "${s}",
  "version": "0.1.0",
  "private": true,
  "scripts": { "dev": "node server.js" },
  "dependencies": { "express": "^4.19.2" }
}
JSON
  fi
done

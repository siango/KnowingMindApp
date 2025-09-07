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

  # healthz.js (เขียนทับได้)
  cat > "$SVC_DIR/src/healthz.js" <<JS
module.exports = function healthz(app, serviceName='${s}') {
  app.get('/healthz', (req, res) => {
    res.status(200).json({ ok: true, service: serviceName, ts: Date.now() });
  });
};
JS

  # server.js (เขียนทับมาตรฐาน)
  cat > "$SVC_DIR/server.js" <<JS
const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, '${s}');

const port = process.env.PORT || ${PORTS[$s]};
app.listen(port, () => console.log('[${s}] listening on ' + port));
JS

  # package.json (ถ้ามีให้บังคับมี scripts.dev และ express; ถ้าไม่มีให้สร้าง)
  PKG="$SVC_DIR/package.json"
  if [ -f "$PKG" ]; then
    P="$PKG" node -e "const fs=require('fs'),p=process.env.P;
      const pkg=JSON.parse(fs.readFileSync(p,'utf8'));
      pkg.scripts=pkg.scripts||{};
      pkg.scripts.dev='node server.js';
      pkg.dependencies=pkg.dependencies||{};
      if(!pkg.dependencies.express) pkg.dependencies.express='^4.19.2';
      fs.writeFileSync(p,JSON.stringify(pkg,null,2));"
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

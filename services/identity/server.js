const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, 'identity');

const port = process.env.PORT || 3101;
app.listen(port, () => console.log('[identity] listening on ' + port));

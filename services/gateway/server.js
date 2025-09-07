const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, 'gateway');

const port = process.env.PORT || 3100;
app.listen(port, () => console.log('[gateway] listening on ' + port));

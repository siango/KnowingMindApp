const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, 'donation');

const port = process.env.PORT || 3104;
app.listen(port, () => console.log('[donation] listening on ' + port));

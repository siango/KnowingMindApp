const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, 'analytics');

const port = process.env.PORT || 3105;
app.listen(port, () => console.log('[analytics] listening on ' + port));

const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, 'journal');

const port = process.env.PORT || 3102;
app.listen(port, () => console.log('[journal] listening on ' + port));

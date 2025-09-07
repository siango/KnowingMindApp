const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, 'ledger');

const port = process.env.PORT || 3103;
app.listen(port, () => console.log('[ledger] listening on ' + port));

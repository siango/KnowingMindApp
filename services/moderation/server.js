const express = require('express');
const app = express();
const healthz = require('./src/healthz');

healthz(app, 'moderation');

const port = process.env.PORT || 3106;
app.listen(port, () => console.log('[moderation] listening on ' + port));

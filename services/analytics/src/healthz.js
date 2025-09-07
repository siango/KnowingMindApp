module.exports = function healthz(app, serviceName='analytics') {
  app.get('/healthz', (req, res) => { res.status(200).json({ ok: true, service: serviceName, ts: Date.now() }); });
};

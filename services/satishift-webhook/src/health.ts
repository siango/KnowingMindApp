import type { Express, Request, Response } from 'express';

export function mountHealth(app: Express) {
  app.get(['/', '/health', '/healthz', '/api/health', '/api/ping', '/ping'], (_req: Request, res: Response) => {
    res.json({
      ok: true,
      service: process.env.K_SERVICE || 'satishift-webhook',
      region: process.env.K_REGION || 'unknown',
      time: new Date().toISOString(),
    });
  });
}

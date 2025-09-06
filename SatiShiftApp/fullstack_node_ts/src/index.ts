import express, { Request, Response } from "express";

const app = express();
const PORT = process.env.PORT ? Number(process.env.PORT) : 8082;

app.get("/", (_req: Request, res: Response) => {
  res.json({ ok: true, service: "satishift-fullstack", root: true });
});

app.get("/api/ping", (_req: Request, res: Response) => {
  res.json({ ok: true, pong: true, ts: new Date().toISOString() });
});

app.get("/health", (_req: Request, res: Response) => res.status(200).send("OK"));

app.listen(PORT, () => {
  console.log(`satishift-fullstack listening on :${PORT}`);
});

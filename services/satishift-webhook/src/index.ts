import { mountHealth } from './health';
import express from "express";
import crypto from "crypto";
const app = express();

// LINE webhook needs raw body to verify signature; use a raw buffer middleware
app.use((req, _res, next) => {
  const chunks: Buffer[] = [];
  req.on("data", (c: Buffer) => chunks.push(c));
  req.on("end", () => {
    const raw = Buffer.concat(chunks);
    // @ts-ignore
    req.rawBody = raw;
    // @ts-ignore
    req.body = JSON.parse(raw.toString("utf-8") || "{}");
    next();
  });
});

function verifyLineSignature(rawBody: Buffer, signature: string | undefined, channelSecret: string | undefined): boolean {
  if (!channelSecret || !signature) return false;
  const hmac = crypto.createHmac("sha256", channelSecret);
  hmac.update(rawBody);
  const expected = hmac.digest("base64");
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
}

app.get("/healthz", (_req, res) => res.json({ ok: true, service: process.env.APP_NAME || "satishift-webhook" }));

app.post("/line/webhook", (req, res) => {
  const sig = req.header("x-line-signature");
  const secret = process.env.LINE_CHANNEL_SECRET;
  const raw = (req as any).rawBody as Buffer;
  const valid = verifyLineSignature(raw || Buffer.from(""), sig, secret);

  if (secret && !valid) {
    return res.status(401).json({ ok: false, error: "invalid signature" });
  }
  console.log("LINE events:", JSON.stringify((req as any).body));

  // Echo: reply with 200 OK, actual reply would call LINE Messaging API (add later)
  return res.json({ ok: true, verified: !!secret && valid });
});

const port = Number(process.env.PORT || 8081);
app.listen(port, () => console.log(`satishift-webhook listening on :${port}`));


mountHealth(app);

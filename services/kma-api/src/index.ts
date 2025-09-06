import express from "express";
const app = express();
app.use(express.json());

// Optional Firestore (enable with ENV ENABLE_FIRESTORE=true)
let useFirestore = (process.env.ENABLE_FIRESTORE || "false").toLowerCase() === "true";
let db: any = null;
const mem = new Map<string, any>();

if (useFirestore) {
  try {
    const {Firestore} = require("@google-cloud/firestore");
    db = new Firestore();
    console.log("Firestore enabled");
  } catch (e) {
    console.warn("Firestore init failed, fallback to memory:", e);
    useFirestore = false;
  }
}

app.get("/healthz", (_req, res) => res.json({ ok: true, service: process.env.APP_NAME || "kma-api", firestore: useFirestore }));

app.get("/api/ping", (_req, res) => res.json({ ok: true, t: Date.now() }));

// Simple KVS demo
app.get("/api/kvs/:key", async (req, res) => {
  const k = req.params.key;
  if (useFirestore) {
    const doc = await db.collection("kvs").doc(k).get();
    return res.json({ key: k, value: doc.exists ? doc.data() : null, backend: "firestore" });
  }
  return res.json({ key: k, value: mem.get(k) ?? null, backend: "memory" });
});

app.put("/api/kvs/:key", async (req, res) => {
  const k = req.params.key;
  const value = req.body?.value ?? null;
  if (useFirestore) {
    await db.collection("kvs").doc(k).set({ value, updated_at: new Date().toISOString() }, { merge: true });
    return res.json({ ok: true, backend: "firestore" });
  }
  mem.set(k, value);
  return res.json({ ok: true, backend: "memory" });
});

const port = Number(process.env.PORT || 8082);
app.listen(port, () => console.log(`kma-api listening on :${port}`));

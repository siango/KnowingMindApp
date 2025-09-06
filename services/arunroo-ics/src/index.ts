import { mountHealth } from './health';
import express from "express";
const app = express();
app.use(express.json());

function buildICS(events: Array<{uid:string, dtstart:string, dtend?:string, summary:string, desc?:string}>) {
  const lines = ["BEGIN:VCALENDAR","VERSION:2.0","PRODID:-//KnowingMindSuite//ArunRoo ICS//TH"];
  for (const ev of events) {
    lines.push("BEGIN:VEVENT");
    lines.push(`UID:${ev.uid}`);
    lines.push(`DTSTAMP:${new Date().toISOString().replace(/[-:]/g,"").split(".")[0]}Z`);
    lines.push(`DTSTART:${ev.dtstart}`);
    if (ev.dtend) lines.push(`DTEND:${ev.dtend}`);
    lines.push(`SUMMARY:${ev.summary}`);
    if (ev.desc) lines.push(`DESCRIPTION:${ev.desc}`);
    lines.push("END:VEVENT");
  }
  lines.push("END:VCALENDAR");
  return lines.join("\r\n");
}

app.get("/healthz", (_req, res) => res.json({ ok: true, service: process.env.APP_NAME || "arunroo-ics" }));

app.get("/ics/content-calendar", async (_req, res) => {
  const sample = [
    { uid: "kma-1@knowing", dtstart: "20250901T013000Z", summary: "ArunRoo Morning Quote" },
    { uid: "kma-2@knowing", dtstart: "20250902T013000Z", summary: "ArunRoo Morning Quote" }
  ];
  const ics = buildICS(sample);
  res.setHeader("Content-Type", "text/calendar; charset=utf-8");
  res.send(ics);
});

const port = Number(process.env.PORT || 8080);
app.listen(port, () => console.log(`arunroo-ics listening on :${port}`));


mountHealth(app);

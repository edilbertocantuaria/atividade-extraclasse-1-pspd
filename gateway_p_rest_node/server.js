import express from "express";
import cors from "cors";
import morgan from "morgan";
import fetch from "node-fetch";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PORT = process.env.PORT || 8081;
const A_REST = process.env.A_REST || "http://localhost:50061";
const B_REST = process.env.B_REST || "http://localhost:50062";

const app = express();
app.use(cors());
app.use(morgan("dev"));
app.use(express.json());

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public/index.html"));
});

app.get("/a/hello", async (req, res) => {
  const name = encodeURIComponent(req.query.name || "mundo");
  const r = await fetch(`${A_REST}/a/hello?name=${name}`);
  const j = await r.json();
  res.json(j);
});

app.get("/b/numbers", async (req, res) => {
  const count = encodeURIComponent(req.query.count || "5");
  const delay_ms = encodeURIComponent(req.query.delay_ms || "0");
  const r = await fetch(`${B_REST}/b/numbers?count=${count}&delay_ms=${delay_ms}`);
  const j = await r.json();
  res.json(j);
});

app.get("/healthz", (_, res) => res.send("ok"));

app.listen(PORT, () => {
  console.log(`Gateway P-REST listening on :${PORT}`);
  console.log(`Using A-REST at ${A_REST} and B-REST at ${B_REST}`);
});

import express from "express";
import cors from "cors";
import morgan from "morgan";
import * as grpc from "@grpc/grpc-js";
import * as protoLoader from "@grpc/proto-loader";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PORT = process.env.PORT || 8080;
const A_ADDR = process.env.A_ADDR || "localhost:50051";
const B_ADDR = process.env.B_ADDR || "localhost:50052";

const PROTO_PATH = path.join(__dirname, "proto/services.proto");
const packageDefinition = protoLoader.loadSync(PROTO_PATH, { keepCase: true, longs: String, enums: String, defaults: true, oneofs: true });
const proto = grpc.loadPackageDefinition(packageDefinition).pspd;

const clientA = new proto.ServiceA(A_ADDR, grpc.credentials.createInsecure());
const clientB = new proto.ServiceB(B_ADDR, grpc.credentials.createInsecure());

const app = express();
app.use(cors());
app.use(morgan("dev"));
app.use(express.json());

app.get("/", (req, res) => res.sendFile(path.join(__dirname, "public/index.html")));

app.get("/a/hello", (req, res) => {
  const name = req.query.name || "mundo";
  clientA.SayHello({ name }, (err, reply) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ from: "A", message: reply.message });
  });
});

app.get("/b/numbers", (req, res) => {
  const count = parseInt(req.query.count || "5", 10);
  const delay_ms = parseInt(req.query.delay_ms || "0", 10);
  const call = clientB.StreamNumbers({ count, delay_ms });
  const values = [];
  call.on("data", (chunk) => values.push(chunk.value));
  call.on("error", (err) => res.status(500).json({ error: err.message }));
  call.on("end", () => res.json({ from: "B", values }));
});

app.get("/healthz", (_, res) => res.send("ok"));

app.listen(PORT, () => {
  console.log(`Gateway P listening on :${PORT}`);
  console.log(`Using A at ${A_ADDR} and B at ${B_ADDR}`);
});

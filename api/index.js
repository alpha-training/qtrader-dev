import express from "express";
import net from "net";
import { serialize, deserialize } from "./c.js";

const app = express();
const port = 3000;

// Change these to match your running q process:
const KDB_HOST = "127.0.0.1";
const KDB_PORT = process.env.QT_C2_PORT
  ? parseInt(process.env.QT_C2_PORT, 10)
  : 5000;

/**
 * Send a query to kdb+ using raw IPC (c.js)
 */
function kdbQuery(qExpression) {
  return new Promise((resolve, reject) => {
    const socket = new net.Socket();

    socket.connect(KDB_PORT, KDB_HOST, () => {
      const msg = serialize(qExpression);
      socket.write(Buffer.from(msg));
    });

    socket.on("data", (data) => {
      try {
        const result = deserialize(new Uint8Array(data).buffer);
        resolve(result);
      } catch (err) {
        reject(err);
      } finally {
        socket.end();
      }
    });

    socket.on("error", (err) => {
      reject(err);
    });
  });
}

// --- EXPRESS ENDPOINTS ----------------------------------------------------

app.get("/ping", (req, res) => {
  res.send("API is alive");
});

app.get("/query", async (req, res) => {
  try {
    const result = await kdbQuery("2+3"); // example query
    res.json({ result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Query failed" });
  }
});

app.listen(port, () => {
  console.log(`API running on http://localhost:${port}`);
});
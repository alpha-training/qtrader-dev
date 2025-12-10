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

app.get("/state", async (req, res) => {
  try {
    const result = await kdbQuery(".c2.procs"); //c2 state of procceses table
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to get state" });
  }
});

app.post("/start/:name", async (req, res) => {
  const pname = req.params.name; // Get the process name from the URL eg:  "start/tp1" and start single process
  try {
    await kdbQuery(`start[${pname}]`);
    res.json({ status: "started", process: pname });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: `Failed to start process ${pname}` });
  }
});

app.post("/start-all", async (req, res) => {
  try {
    await kdbQuery("startall[]"); // start all proccesses
    res.json({ status: "started all processes" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to start all processes" });
  }
});

app.post("/stop/:name", async (req, res) => {
  const pname = req.params.name; // e.g., "tp1"
  try {
    await kdbQuery(`pkill[${pname}]`);
    res.json({ status: "stopped", process: pname });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: `Failed to stop process ${pname}` });
  }
});

app.post("/stopall", async (req, res) => {
  try {
    await kdbQuery("pkillall[]");
    res.json({ status: "stopped all processes" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to stop all processes" });
  }
});

app.get("/logs/:name", async (req, res) => {
  const pname = req.params.name; // e.g., "tp1"
  try {
    // Call the kdb+ tail function for this process
    const result = await kdbQuery(`tail["${pname}"]`);
    res.json({ process: pname, tail: result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: `Failed to read logs for process ${pname}` });
  }
});


app.listen(port, () => {
  console.log(`API running on http://localhost:${port}`);
});
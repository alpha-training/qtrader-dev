import express from "express";
import WebSocket from "ws";
import fs from "fs";
const app = express();
const port = 3000;

// Change these to match your running q process:

const KDB_PORT = fs.readFileSync("local_base_port.txt", "utf8").trim();
const KDB_WS_URL = "ws://127.0.0.1:" + KDB_PORT;

/* ----------------------- kdb websocket ----------------------- */
let qws, kdbReady = false;
const kdbQueue = [];
const kdbCallbacks = [];

function openKdb() {
  qws = new WebSocket(KDB_WS_URL);
  qws.onopen = () => { kdbReady = true; console.log("kdb ws open"); };
  qws.onclose = (e) => { kdbReady = false; log("[kdb] ws close", e?.code, e?.reason ?? ""); };
  qws.onerror = (e) => console.log("kdb ws error", e?.message ?? e);

  qws.onmessage = (msg) => {
    try {
      const data = msg.data.toString();
      const a = JSON.parse(data);

      if(a.callback == "upd"){
        stream(a.result[0], a.result[1]);
        return;
      }

      console.log("Async update received for ", a.callback);

      // Find the matching callback by callback name
      const cbIndex = kdbCallbacks.findIndex(c => c.callbackName === a.callback);

      if (cbIndex >= 0) {
        const cb = kdbCallbacks.splice(cbIndex, 1)[0]; // remove from array
        cb.resolve(a.result);  // resolve the promise
      } else {
        console.log("No pending callback matches", a.callback);
      }

    } catch (err) {
      console.error("[kdb] onmessage error:", err);
    }
  };
}

function stream (t, x) {
  let n = x.length;
  //console.log("Streaming update received for " + t + " with " + n + " records");
  switch(t){
    case "process":
    //  console.log("Process update received with " + n + " records");
      break;
  }
}

function sendToKdb(callback, cmd) {
  return new Promise((resolve, reject) => {
    if (kdbReady && qws.readyState === WebSocket.OPEN) {
      const arg = { callback, cmd };
      qws.send(JSON.stringify(arg));
      console.log("Pushing callbacks");
      kdbCallbacks.push({ callbackName: callback, resolve, reject });
    } else {
      kdbQueue.push({ cmd, callback, resolve, reject });
    }
  });
}


// --- EXPRESS ENDPOINTS ----------------------------------------------------

app.get("/ping", (req, res) => {
  res.send("API is alive");
});

app.get('/users', (req, res) => {
  res.json([{ name: 'Alice' }, { name: 'Bob' }]);
});

app.get("/query", async (req, res) => {
  try {
    const result = await sendToKdb("query", "4+8");
    res.json({ result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Query failed" });
  }
});

app.get("/state", async (req, res) => {
  try {
    const result = await sendToKdb(".c2.conns", ".c2.conns");
    res.json({ result });
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

openKdb();

app.listen(port, () => {
  console.log(`API running on http://localhost:${port}`);
});
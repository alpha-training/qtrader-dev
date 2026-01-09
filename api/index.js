// api/index.js
import express from "express";
import WebSocket from "ws";
import fs from "fs";

const app = express();
const port = 3000;

app.use(express.json());

// Change these to match your running q process:
const KDB_PORT = fs.readFileSync("local_base_port.txt", "utf8").trim();
const KDB_WS_URL = "ws://127.0.0.1:" + KDB_PORT;

/* ----------------------- kdb websocket ----------------------- */
let qws;
let kdbReady = false;

const kdbQueue = [];
const kdbCallbacks = [];

// generate unique callback names so responses don't clash
let cbSeq = 0;
function nextCallback(prefix = "cb") {
  cbSeq += 1;
  return `${prefix}_${Date.now()}_${cbSeq}`;
}

// only allow "process-name-ish" values
function sanitizeProcName(name) {
  if (!/^[A-Za-z0-9._-]+$/.test(name)) {
    throw new Error(`Invalid process name: ${name}`);
  }
  return name;
}

function flushQueue() {
  while (kdbReady && qws?.readyState === WebSocket.OPEN && kdbQueue.length) {
    const { cmd, callback, resolve, reject } = kdbQueue.shift();
    try {
      const arg = { callback, cmd };
      qws.send(JSON.stringify(arg));
      kdbCallbacks.push({ callbackName: callback, resolve, reject });
    } catch (e) {
      reject(e);
    }
  }
}

function stream(_t, _x) {
  // keep if you need streaming updates
}

function openKdb() {
  qws = new WebSocket(KDB_WS_URL);

  qws.onopen = () => {
    kdbReady = true;
    console.log("kdb ws open:", KDB_WS_URL);
    flushQueue();
  };

  qws.onclose = (e) => {
    kdbReady = false;
    console.log("[kdb] ws close", e?.code, e?.reason ?? "");
    // Optional: auto-reconnect (simple)
    // setTimeout(openKdb, 1000);
  };

  qws.onerror = (e) => console.log("kdb ws error", e?.message ?? e);

  qws.onmessage = (msg) => {
    try {
      const data = msg.data.toString();
      const a = JSON.parse(data);

      // streaming updates
      if (a.callback === "upd") {
        stream(a.result?.[0], a.result?.[1]);
        return;
      }

      // Find matching callback
      const cbIndex = kdbCallbacks.findIndex((c) => c.callbackName === a.callback);
      if (cbIndex < 0) {
        console.log("No pending callback matches", a.callback);
        return;
      }

      const cb = kdbCallbacks.splice(cbIndex, 1)[0];

      // IMPORTANT: propagate kdb/q errors properly
      if (a.error) {
        cb.reject(new Error(a.error));
        return;
      }

      cb.resolve(a.result);
    } catch (err) {
      console.error("[kdb] onmessage error:", err);
    }
  };
}

/**
 * Low-level request helper.
 * callback must be unique per request.
 */
function sendToKdb(callback, cmd) {
  return new Promise((resolve, reject) => {
    if (kdbReady && qws?.readyState === WebSocket.OPEN) {
      try {
        qws.send(JSON.stringify({ callback, cmd }));
        kdbCallbacks.push({ callbackName: callback, resolve, reject });
      } catch (e) {
        reject(e);
      }
    } else {
      kdbQueue.push({ cmd, callback, resolve, reject });
    }
  });
}

/**
 * High-level query helper.
 */
async function kdbQuery(cmd, prefix = "q") {
  const callback = nextCallback(prefix);
  return sendToKdb(callback, cmd);
}

// --- EXPRESS ENDPOINTS ----------------------------------------------------

app.get("/ping", (_req, res) => {
  res.send("API is alive");
});

app.get("/query", async (_req, res) => {
  try {
    const result = await kdbQuery("4+8", "query");
    res.json({ result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Query failed" });
  }
});

app.get("/state", async (_req, res) => {
  try {
    const result = await kdbQuery(".c2.conns", "state");
    res.json({ result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to get state" });
  }
});

/**
 * Start a single process
 * Sends: .c2.up[`rdb]
 */
app.post("/start/:name", async (req, res) => {
  try {
    const pname = sanitizeProcName(req.params.name);

    // ✅ CORRECT: include a q symbol using a backtick, WITHOUT an extra backslash
    await kdbQuery(`.c2.up[\`${pname}]`, "start");

    res.json({ status: "started", process: pname });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: `Failed to start process ${req.params.name}` });
  }
});

/**
 * Start all processes
 */
app.post("/start-all", async (_req, res) => {
  try {
    await kdbQuery(".c2.upall[]", "startall");
    res.json({ status: "started all processes" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to start all processes" });
  }
});

/**
 * Stop a single process
 * Sends: .c2.down[`rdb]
 */
app.post("/stop/:name", async (req, res) => {
  try {
    const pname = sanitizeProcName(req.params.name);

    // ✅ CORRECT: q symbol quoting
    await kdbQuery(`.c2.down[\`${pname}]`, "stop");

    res.json({ status: "stopped", process: pname });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: `Failed to stop process ${req.params.name}` });
  }
});

/**
 * Stop all processes
 * NOTE: confirm in your build that downall[] exists; otherwise change to whatever your c2 exposes.
 */
app.post("/stopall", async (_req, res) => {
  try {
    await kdbQuery(".c2.downall[]", "stopall");
    res.json({ status: "stopped all processes" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to stop all processes" });
  }
});

app.get("/logs/:name", async (req, res) => {
  try {
    const pname = sanitizeProcName(req.params.name);
    const result = await kdbQuery(`tail["${pname}"]`, "tail");
    res.json({ process: pname, tail: result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: `Failed to read logs for process ${req.params.name}` });
  }
});

openKdb();

app.listen(port, () => {
  console.log(`API running on http://localhost:${port}`);
});

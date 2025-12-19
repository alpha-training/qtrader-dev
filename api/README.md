# qTrader API

A lightweight Express.js API that connects to kdb+ using raw IPC via `c.js`.

## 🚀 Getting Started

### 1. **Install dependencies**

```bash
npm install
```

### 2. **Ensure the C2 environment variable is set in .env**

```bash
export QT_C2_PORT=5000
```

If you are developing on a shared box, use a different port to your colleagues.

### 3. **Start your kdb+ process**

Make sure your c2 process is running e.g.

```bash
q qtrader.q -name c2
```

### 4. **Start the API**

```bash
npm start
```

You should see:

```
Connecting to kdb on 127.0.0.1 5000
API running on http://localhost:3000
```

---

## 🧪 Testing the API

### Ping endpoint:

```bash
curl http://localhost:3000/ping
```

### Test kdb query:

```bash
curl http://localhost:3000/query
```

## Postman
[Postman](https://www.postman.com) is a very useful tool for testing against APIs.

---

## ⚙️ Configuration

Environment variables:

| Variable       | Description                        |
|----------------|------------------------------------|
| `QT_C2_PORT`   | Port where kdb+ IPC is running     |

---

## 📁 Project Structure

```
api/
  index.js       # Express API
  c.js           # kdb IPC serializer/deserializer
  package.json   # Dependencies + scripts
```

---

## 📜 License

Internal use. Not for external distribution.
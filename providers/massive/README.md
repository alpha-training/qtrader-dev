# Massive.com Adapter for qtrader

This repository handles the connection between the **Massive.com** market data API and our **kdb+** system. It handles both real-time streaming data and historical data downloads.

---

## How to Run

If you just want to get the data flowing, follow these steps.

### 1. Prerequisites
Ensure you have the following installed in your VS Code environment:
* **kdb+/q** (with `embedPy` installed)
* **Python 3.x**
* The Massive Python client:
    ```bash
    pip install massive
    ```

### 2. Configuration
Before running, ensure your API Key is set.
Open `src/qtrader/providers/massive/realtime/stream.py` and check the client setup:
```python
client = WebSocketClient(
    api_key="Your_API_Key",
    feed=Feed.Delayed,
    market=Market.Stocks
)
```
To change which stocks you watch or the speed of the data, open `stream.py` and find the `SUBSCRIPTIONS` list.

```python
# stream.py example

# Format is: "Prefix.Symbol"
SUBSCRIPTIONS = ["A.AAPL", "AM.MSFT", "T.*"]
```

### How to specify Bar Duration (Prefixes)
The letter before the dot determines the data type and duration.

| Prefix | Description | Example |
| :--- | :--- | :--- |
| **A** | **Second Bars** (Aggregates per second) | `"A.AAPL"` |
| **AM** | **Minute Bars** (Aggregates per minute) | `"AM.AAPL"` |
| **T** | **Trades** (Every single tick) | `"T.AAPL"` |
| **Q** | **Quotes** (Top of book bid/ask) | `"Q.AAPL"` |

### Examples
* **All stocks, 1-second bars:** `["A.*"]`
* **Apple and Microsoft, 1-minute bars:** `["AM.AAPL", "AM.MSFT"]`
* **Trades only (no bars) for Tesla:** `["T.TSLA"]`

### Feed Options (`feed=...`)
| Option | Description |
| :--- | :--- |
| `Feed.Delayed` | **15-minute delayed data.** Free to use. Ideal for development and testing. |
| `Feed.RealTime` | **Live data.** Requires a premium subscription/license. |

### Market Options (`market=...`)
| Option | Description |
| :--- | :--- |
| `Market.Stocks` | US Equities (Stocks & ETFs). |
| `Market.Crypto` | Crypto pairs (e.g., BTC-USD). |
| `Market.Forex` | Currency pairs (e.g., EUR-USD). |
| `Market.Options` | Equity Options. |

### 3. Running the Real-Time Feed
We do not run the Python script directly. We run the **q feed handler**, which automatically loads the Python stream in the background.

1. Open the **Terminal** in VS Code.
2. Navigate to the realtime directory:
   ```bash
   cd src/qtrader/providers/massive/realtime
   ```
3. Run the q script:
   ```bash
   q feed.q
   ```

**What happens next?**
* The system connects to Massive.com..
* Every 1 second, a list of Time, Sym, Open, High, Low, Close will be printed to the console (or sent to the tickerplant).

## Configuration: Tickers & Bar

## Developer Notes

### How it works (The Architecture)
We use **embedPy** to bridge Python and q.
1. **Python (`stream.py`)**: Connects to the websocket in a background thread and collects data into a buffer.
2. **q (`feed.q`)**: Runs a timer every 1 second. It tells Python to "drain" that buffer, then flips the data into kdb+ lists and processes it.


### Reference Documentation
* **Official Massive Python Docs:** [https://github.com/massive-com/client-python](https://github.com/massive-com/client-python)
* **embedPy:** [https://code.kx.com/platform/embedpy/](https://code.kx.com/platform/embedpy/)
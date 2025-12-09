# src/qtrader/providers/massiveapi/normalize.py

from datetime import datetime
import pandas as pd

def normalize_aggs(aggs, ticker=None):
    """
    Convert Massive aggregate bars into a pandas DataFrame.
    """
    rows = []
    for a in aggs:
        ts = getattr(a, "timestamp", None)  # historical
        if ts is None:
            ts = getattr(a, "start_timestamp", None)  # realtime fallback
        if ts is None:
            raise ValueError(f"No timestamp found for aggregate: {a}")
        
        rows.append({
            "datetime": datetime.utcfromtimestamp(ts / 1000),
            "ticker": ticker,
            "open": a.open,
            "high": a.high,
            "low": a.low,
            "close": a.close,
            "volume": a.volume,
        })

    return pd.DataFrame(rows)

# src/qtrader/providers/massiveapi/historical/downloader.py
import csv
from .rest import MassiveREST
from ..normalize import normalize_aggs
API_KEY = "rSQLz8C1muscWBydEkoAWpW4RH9CW_wq"

class HistoricalDownloader:
    def __init__(self, api_key: str):
        self.client = MassiveREST(api_key=api_key)

    def download_ticker(
        self,
        ticker: str,
        from_: str = "2023-01-01",
        to: str = None,
        limit: int = 50000,
        filename: str = None
    ):
        """
        Fetch and normalize historical bars for a single ticker, then save to CSV.
        """
        raw = self.client.fetch_aggs(ticker=ticker, from_=from_, to=to, limit=limit)
        normalized = normalize_aggs(raw)
        filename = filename or f"{ticker}_historical.csv"

        with open(filename, mode="w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=["datetime", "open", "high", "low", "close", "volume"])
            writer.writeheader()
            writer.writerows(normalized)
        
        print(f"Saved {len(normalized)} rows to {filename}")
        return normalized

    def download_multiple(self, tickers, from_="2023-01-01", to=None, limit=50000):
        """
        Fetch multiple tickers.
        """
        results = {}
        for ticker in tickers:
            results[ticker] = self.download_ticker(ticker, from_=from_, to=to, limit=limit)
        return results

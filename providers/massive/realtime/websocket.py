# src/qtrader/providers/massiveapi/realtime/websocket.py

from src.qtrader.providers.massive.realtime.stream import EquityStream
import pandas as pd

class WSHandler:
    def __init__(self, api_key):
        self.stream = EquityStream(api_key)
        self.data: pd.DataFrame = pd.DataFrame()

    def subscribe(self, *tickers):
        self.stream.subscribe(*tickers)

    def start(self):
        """Start streaming and accumulate data in self.data."""
        def collect(df):
            self.data = pd.concat([self.data, df], ignore_index=True)
            # optional: flush to CSV or DB every N rows
            if len(self.data) >= 1000:
                print(f"Buffered {len(self.data)} rows. You could flush to DB here.")
                # e.g., self.data.to_csv("realtime.csv", mode="a", header=False, index=False)
                self.data = pd.DataFrame()  # reset buffer

        self.stream.on_message(collect)
        self.stream.run()

import yfinance as yf
import pandas as pd
from qtrader.providers.yahoo.normalize import normalize_history

class YahooHistorical:
    def get_bars(self, ticker: str, start_date: str = None, end_date: str = None, period: str = "1mo", interval: str = "1d") -> pd.DataFrame:
        if start_date:
            df = yf.download(ticker, start=start_date, end=end_date, interval=interval, auto_adjust=True, progress=False)
        else:
            df = yf.download(ticker, period=period, interval=interval, auto_adjust=True, progress=False)

        return normalize_history(df, ticker)
    

if __name__ == "__main__":
    client = YahooHistorical()
    print("Fetching MSFT data...")
    df = client.get_bars("MSFT", period="5d", interval="1h")
    print(df.head())
    print("\nData Types:")
    print(df.dtypes)
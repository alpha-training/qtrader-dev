# src/qtrader/providers/massiveapi/historical/rest.py
from massive import RESTClient
from datetime import datetime

class MassiveREST:
    def __init__(self, api_key: str):
        self.client = RESTClient(api_key=api_key)

    def fetch_aggs(
        self,
        ticker: str,
        multiplier: int = 1,
        timespan: str = "minute",
        from_: str = "2023-01-01",
        to: str = None,
        limit: int = 50000
    ):
        """
        Fetch historical aggregate bars for a given ticker.
        """
        to = to or datetime.utcnow().strftime("%Y-%m-%d")
        aggs = []
        for a in self.client.list_aggs(
            ticker=ticker,
            multiplier=multiplier,
            timespan=timespan,
            from_=from_,
            to=to,
            limit=limit
        ):
            aggs.append(a)
        return aggs

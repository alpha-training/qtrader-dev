# src/qtrader/providers/massiveapi/historical/ingest.py

from typing import List, Dict
from ..normalize import normalize_aggs
import pandas as pd

class HistoricalIngest:
    """
    Minimal ingest class for Massive historical data.
    """

    def __init__(self):
        pass

    def ingest(self, data: List[dict]) -> List[dict]:
        """
        Accepts raw Agg data (from downloader.fetch_aggs),
        normalizes it, and returns it for further processing
        or saving.
        """
        # If the data is already normalized, you can skip this step
        # Otherwise, call normalize_aggs
        normalized = normalize_aggs(data)
        return normalized

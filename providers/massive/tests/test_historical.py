# src/qtrader/providers/massive/tests/test_historical.py

import pytest
from qtrader.providers.massive.historical.rest import MassiveREST
from qtrader.providers.massive.historical.ingest import HistoricalIngest
from qtrader.providers.massive.historical.downloader import HistoricalDownloader

API_KEY = "rSQLz8C1muscWBydEkoAWpW4RH9CW_wq"

def test_download_and_ingest():
    client = MassiveREST(API_KEY)
    raw = client.fetch_aggs("AAPL", from_="2023-06-01", to="2023-06-02", limit=2)

    # Ensure we actually got data
    assert len(raw) > 0, "No raw data returned"

    ingest = HistoricalIngest()
    normalized = ingest.ingest(raw)

    # normalized should be a pandas DataFrame
    import pandas as pd
    assert isinstance(normalized, pd.DataFrame), "Ingest did not return a DataFrame"

    # Check required columns exist
    expected_cols = {"datetime", "open", "close", "high", "low", "volume"}
    assert expected_cols.issubset(set(normalized.columns)), f"Missing columns: {expected_cols - set(normalized.columns)}"

    # Optional: check DataFrame is not empty
    assert not normalized.empty, "Normalized DataFrame is empty"
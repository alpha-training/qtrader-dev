# qtrader/providers/massiveapi/tests/test_realtime.py

import pytest
from unittest.mock import MagicMock
from qtrader.providers.massive.realtime.stream import MassiveStream

API_KEY = "fake-api-key"

def test_subscribe_trades_single_ticker():
    stream = MassiveStream(API_KEY)
    stream.ws = MagicMock()

    ticker = "AAPL"
    stream.subscribe_trades(ticker)

    # ws.subscribe is called once with a list containing one string
    stream.ws.subscribe.assert_called_once_with(["trades:AAPL"])

def test_subscribe_trades_multiple_tickers():
    stream = MassiveStream(API_KEY)
    stream.ws = MagicMock()

    tickers = ["AAPL", "MSFT"]
    stream.subscribe_trades(tickers)

    # ws.subscribe is called once with all tickers in a single list
    stream.ws.subscribe.assert_called_once_with(["trades:AAPL", "trades:MSFT"])

def test_subscribe_quotes_single_ticker():
    stream = MassiveStream(API_KEY)
    stream.ws = MagicMock()

    ticker = "GOOG"
    stream.subscribe_quotes(ticker)

    # ws.subscribe is called once with a list containing one string
    stream.ws.subscribe.assert_called_once_with(["quotes:GOOG"])

def test_subscribe_quotes_multiple_tickers():
    stream = MassiveStream(API_KEY)
    stream.ws = MagicMock()

    tickers = ["GOOG", "TSLA"]
    stream.subscribe_quotes(tickers)

    # ws.subscribe is called once with all tickers in a single list
    stream.ws.subscribe.assert_called_once_with(["quotes:GOOG", "quotes:TSLA"])

def test_start_calls_run_with_callback():
    stream = MassiveStream(API_KEY)
    stream.ws = MagicMock()

    def fake_callback(msg):
        return msg

    stream.start(fake_callback)

    stream.ws.run.assert_called_once_with(fake_callback)

def test_normalize_tickers_returns_list():
    stream = MassiveStream(API_KEY)

    assert stream._normalize_tickers("AAPL") == ["AAPL"]
    assert stream._normalize_tickers(["AAPL", "MSFT"]) == ["AAPL", "MSFT"]

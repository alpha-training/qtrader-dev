from massive import WebSocketClient
from massive.websocket.models import WebSocketMessage, Feed, Market
from typing import List
from collections import deque
import threading

data_buffer = deque()

def drain_buffer():
    res = list(data_buffer)
    data_buffer.clear()
    return res

client = WebSocketClient(
    api_key="rSQLz8C1muscWBydEkoAWpW4RH9CW_wq",
    feed=Feed.Delayed,
    market=Market.Stocks
)
client.subscribe("A.*")

def handle_msg(msgs: List[WebSocketMessage]):
    for m in msgs:
        try:
            # Explicit Tuple Creation (tablename, Time, Sym, Open, High, Low, Close, Volume)
            row = (
                m.event_type,
                m.start_timestamp,
                m.symbol,
                m.high,
                m.low,
                m.open,
                m.close,
                m.volume
            )
            data_buffer.append(row)
        except AttributeError:
            pass

def run_massive_feed():
    try:
        client.run(handle_msg)
    except Exception as e:
        print(f"Feed Error: {e}")

t = threading.Thread(target=run_massive_feed)
t.daemon = True
t.start()
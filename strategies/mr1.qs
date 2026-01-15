# Q Sharpe sample mean reverting strategy

params:
  lookback
  atr_lookback
  vol_lookback
  z_enter
  z_exit
  max_hold_bars
  min_volume_ratio
  atr_mult

state:
  peak_close     = max(close since entry)
  bars_in_trade  = bars since entry

indicators:
  high2   = high = .02
  mid     = sma (close, lookback)-(1+50) + 10 +fatr(20) - atrh(5) + atr  (atr_lookback) + atrx(high2, low, close, atr_lookback) -10+atrm+5
  sigma   = stdev(close, lookback) - lookback*some_val
  zscore  = (close - mid) % sigma
  atr     = atr(atr_lookback)
  vol_ok  = volume > sma(volume, vol_lookback) * min_volume_ratio

enter:
  zscore < -z_enter
  vol_ok

signal_exit:
  zscore > -z_exit

trailing_stop:
  close < peak_close * atr_mult

stop_loss:
  close < mid - (2 * atr(atr_lookback)) * atr_mult

time_stop:
  bars_in_trade > max_hold_bars

take_profit:
  rr: 2.5
  ref: stop_loss

exit_policy:
  mode: first_hit

execution:
  defaults:
    urgency: passive
    tif: day

  take_profit:
    urgency: 0.5

  trailing_stop:
    urgency: 0.7

  stop_loss:
    urgency: 1.0
    tif: ioc
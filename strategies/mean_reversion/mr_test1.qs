vars:
  lookback
  z_enter
  z_exit
  max_hold_bars
  min_volume_ratio
  atr_mult

indicators:
  mid     = sma(close, lookback)
  sigma   = stdev(close, lookback)
  zscore  = (close - mid) % sigma
  atr     = atr(14)
  vol_ok  = volume > sma(volume, 20) * min_volume_ratio

enter:
  zscore < -z_enter
  vol_ok

exit:
  zscore > -z_exit

stop_loss:
  close < mid - atr * atr_mult

time_stop:
  bars_in_trade > max_hold_bars

execution:
  open_style: passive
  close_style: aggressive
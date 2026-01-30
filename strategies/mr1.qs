# mr1.qs - v0.1.0

params:
  lookback, atr_lookback, vol_lookback
  z_enter, z_exit
  max_hold_bars, min_volume_ratio
  atr_mult
  tp_r_mult
  max_loss_r
  trail_activate_r
  trail_giveback_r
  short_enter_z
  short_exit_z

indicators:
  mid     = sma(close, lookback)
  zscore  = (close - mid) / stdev(close, lookback)
  atr1    = atr(atr_lookback)
  vol_ok  = volume > sma(volume, vol_lookback) * min_volume_ratio

enter:
  zscore < -z_enter
  vol_ok

exits:
  signal_exit:
    zscore > -z_exit

  time_stop:
    (bars since entry) > max_hold_bars

  stop_loss:
    close < mid - (atr1 * atr_mult)
    
  pnl_stop:
    (-upnl_r) >= max_loss_r
  
  pnl_trailing:
    mfe_r >= trail_activate_r
    (mfe_r - upnl_r) >= trail_giveback_r

  take_profit:
    r_multiple: tp_r_mult
    ref: stop_loss

exit_policy:
  mode: first_hit

[short]
z_enter: short_enter_z
z_exit: short_exit_z
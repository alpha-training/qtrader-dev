# exec1.qs
# Execution behaviour

[execution]

defaults:
  urgency: passive
  tif: day

pnl_stop:
  urgency: 1.0
  tif: ioc

stop_loss:
  urgency: 1.0
  tif: ioc

pnl_trailing:
  urgency: 0.7

take_profit:
  urgency: 0.4

signal_exit:
  urgency: 0.4
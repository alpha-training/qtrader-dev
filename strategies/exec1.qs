# exec1.qs - v0.1.0

[execution]

defaults:
  urgency: passive
  tif: day

entry:
  urgency: mid
  tif: gtc

# "Hard" stops usually need "this_bar" or "at_limit" logic
risk_exits:
  targets: [pnl_stop, stop_loss]
  urgency: aggressive
  tif: ioc

# "Soft" exits can afford to wait for the next open/passive fills
alpha_exits:
  targets: [take_profit, signal_exit, pnl_trailing]
  urgency: 0.4

[short]
defaults:
  urgency: 0.6
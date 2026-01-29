\l /home/iwickham/qi/qi.q
.qi.include`ta
/.ta.cfg.loadJSON`test.json
/.qi.includecfg"ta/settings.csv"

\l /data/alf/polygon/hdb/us_stocks_sip

/(2022.03.02 2022.03.10),sym in`AAPL`TSLA

lookback:50
vol_lookback:20
max_hold_bars:60
z_enter:1
z_exit:-1
min_volume_ratio:2f
atr_mult:2.5
atr_lookback:30
init_state:(0;0n;0n;0;0n;0n;`)
market_hours:(14:30:00 21:00:00)

/ buy the dip
ks:{[dates;syms]
    tt:select from bar1m where date within dates,time within market_hours,sym in syms;
    tt:update date:time.date from tt;
    a:update mid:mavg[lookback;close],sigma:mdev[lookback;close]by sym from tt;
    a1:update z:(close-mid)%sigma by sym from a;
    a2:update atr:atr_lookback mavg(high-low)|(abs high-prev close)|(abs low-prev close)by sym from a1;
    a3:update enter_long:((z<-1)&(volume>min_volume_ratio*mavg[vol_lookback;volume]))by sym from a2;
    a4:update return:next(close-prev close)%close by sym from a3;
    a5:update state:backtest_logic\[init_state;([] time;z;close;mid;atr;enter_long)]by sym from a4;
    a6:update port_return:state[;0]*return by sym from a5;
    a7:update equity:prds 1+port_return by sym from a6;
    a8:update dd:(equity-((|\)equity))%((|\)equity)by sym from a7;
    stratacc_return:select -1#equity by sym from a8;
    sharpe:select sharpe:sqrt[98280]*avg[port_return]%dev[port_return]by sym from a8;
    min_drawdown:select max_dd:min dd by sym from a8;
    stratacc_return lj sharpe lj min_drawdown
  }

/ --- Constants ---
z_exit:-1
atr_mult:2.5
max_hold_bars:60
rr_mult:10

/ --- The Backtest Engine ---
/ s = state from previous row
/ r = current row data (dictionary)
backtest_logic:{[s;r]
  pos:s 0; ep:s 1; peak:s 2; bars:s 3; stop:s 4; target:s 5;
  
  if[pos=0;
    if[r`enter_long;
      if[r[`time]>=21:00:00;:(0;0n;0n;0;0n;0n;`)];
      entry_stop:r[`mid]-r[`atr]*atr_mult;
      dist:r[`close]-entry_stop;
      tp:r[`close]+(dist*rr_mult);
      :(1;r`close;r`close;1;entry_stop;tp;`);
    ];
    :(0;0n;0n;0;0n;0n;`);
  ];
  new_peak:max(peak;r`close);
  new_bars:bars+1;
  trailing_stop:new_peak-r[`atr]*atr_mult;
  hard_stop:r[`mid]-r[`atr]*atr_mult;
  exit1:0b;
  reason:`;

  if[r[`z]>neg z_exit;exit1:1b;reason:`signal];
  if[r[`close]<trailing_stop;exit1:1b;reason:`trailing];
  if[r[`close]<hard_stop;exit1:1b;reason:`stop_loss];
  if[new_bars>max_hold_bars;exit1:1b;reason:`time_stop];
  if[r[`close]>target;exit1:1b;reason:`take_profit];
  if[r[`time]>=21:00:00; exit1:1b; reason:`eod_close];

  if[exit1;:(0;0n;0n;0;0n;0n;reason)];
  :(1;ep;new_peak;new_bars;hard_stop;target;`)
 }




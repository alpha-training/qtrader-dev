\l /data/alf/polygon/hdb/us_stocks_sip

t:select from bar1m where date within 2025.08.05 2025.09.19,sym=`A;
P:(!). flip((`lookback;20);(`atr_lookback;14);(`vol_lookback;20);(`min_volume_ratio;1.5);(`z_enter;2.0));

sma:{[n;x] @[n mavg x;til n-1;:;0n]}; / sma[20; close]
stdev:{[n;x] @[n mdev x;til n-1;:;0n]};/ /stdev[20; close]
atr:{[n;h;l;c] / atr[14; high; low; close]
  tr:max(h-l;abs h-prev c;abs l-prev c); / Calculate True Range
  start:avg tr 1+til n;                    / Calculate Initial Average
  func:{[n;acc;new] (new+acc*n-1)%n}[n]; / Wilder's Smoothing Logic
  (n#0n),start,func\[start;(n+1)_tr]      / Scan and join
 };

mr:{[table;dateRange;syms] / mr[bar1m;2025.08.05 2025.09.19;`A]
  if[1~count syms;syms:enlist syms];
  t:select from table where date within dateRange,sym in syms;
  t:update SMA:sma[P`lookback;close],
    StDev:stdev[P`lookback;close],
    ATR:atr[P`atr_lookback;high;low;close],
    vol_avg:sma[P`vol_lookback;volume]by sym from t;
  t:update zscore:(close-SMA)%StDev,vol_ok:(not null vol_avg)&(volume>vol_avg*P`min_volume_ratio) from t;
  t:update entry_signal:(not null zscore)&(zscore<neg P`z_enter)&vol_ok from t;
  d:select i,close,SMA,ATR,zscore,entry_signal from t;
  r:flip step\[(0b;0n;0n;0N;0n;`);d];
  t:update in_trade:r 0,entry_price:r 1,exit_reason:r 5 from t;
  t:update pnl_pts:close-entry_price,pnl_pct:(close-entry_price)%entry_price from t where not null exit_reason;
  t:select date,time,sym,close,entry_price,in_trade,exit_reason,pnl_pts,pnl_pct,zscore from t;
  t
 }

step:{[state;row]
  status:state 0;
  if[not status;
     if[row`entry_signal;
        sl_ref:row[`SMA]-(row[`ATR]*P`atr_mult);
        risk:row[`close]-sl_ref;
        tp_price:row[`close]+(risk*2.5);
        :(1b;row[`close];row[`close];row[`i];tp_price;`)
     ];
     :(0b;0n;0n;0N;0n;`)
  ];
  entry_px:state 1;
  peak_px:state 2;
  entry_idx:state 3;
  tp_price:state 4;
  
  new_peak:max(peak_px;row[`close]);
  trail_sl:new_peak-(row[`ATR]*P`atr_mult);
  current_sl:row[`SMA]-(row[`ATR]*P`atr_mult);
 
  if[row[`zscore]>neg P`z_exit;:(0b;entry_px;0n;0n;0n;`signal_exit)];    
  if[(row[`i]-entry_idx)>P`max_hold_bars;:(0b;entry_px;0n;0n;0n;`time_stop)];
  if[row[`close]<(row[`SMA]-row[`ATR]*P`atr_mult);:(0b;entry_px;0n;0n;0n;`stop_loss)];
  if[row[`close]<(new_peak-row[`ATR]*P`atr_mult);:(0b;entry_px;0n;0n;0n;`trailing_stop)];
  if[row[`close]>=tp_px;:(0b;entry_px;0n;0n;0n;`take_profit)];
 };

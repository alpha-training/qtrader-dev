/if[0<count d:.qi.opts`data; system"l ",d]
if[`data in key cmd:.Q.opt .z.x;system raze"l ",cmd`data];

.ta.sma:{[x;n] @[n mavg x;til n-1;:;0n]}; / sma[20; close]
.ta.stdev:{[x;n] @[n mdev x;til n-1;:;0n]};/ /stdev[20; close]
.ta.atr:{[h;l;c;n] / atr[high; low; close;14]
  tr:max(h-l;abs h-prev c;abs l-prev c); / Calculate True Range
  start:avg tr 1+til n;                    / Calculate Initial Average
  func:{[n;acc;new] (new+acc*n-1)%n}[n]; / Wilder's Smoothing Logic
  (n#0n),start,func\[start;(n+1)_tr]      / Scan and join
 };




.ta.inds:1!([]indicator:key d),'(uj/)enlist each d:`$'(.j.k raze read0`:stack.json)`indicators;
\l /data/alf/polygon/hdb/us_stocks_sip
/tab:select from bar1m where date=max date,sym in`AAPL`TSLA;
\d .eh
t1:`ndep xasc update up:0b,ndep:count each depends_on from .ta.inds;
/update enlist[depends_on]from`t1 where 1=count each exec depends_on from t1;



order:();
getOrder:{ / the only purpose of this function is to ensure the varible "order" dictates the correct order for the indicators to be run
  remaining:exec indicator from t1 where not up;
  if[0=count remaining;:0b];
  ready:except[exec indicator from t1 where 0=ndep;order];
  order::order,ready;
  if[count ready;
    update up:1b from`t1 where indicator in ready;
    update depends_on:depends_on except\:ready,ndep:count each depends_on except\:ready from`t1];
    count ready
 };
getOrder/[1b];


pindictors:("mid:.ta.sma[close;40]";
    "zscore:(close - mid) % sigma";
    "atr1:.ta.atr[high;low;close;30]";
    "vol_ok:volume > .ta.sma[volume;20] * 2";
    "sigma:.ta.stdev[close;40]")

u:parse each pindictors;
newp:u u[;1]?order asc order?u[;1];

run:{[strat;dates;syms;bars] / .eh.run[`;2025.09.15 2025.10.15;`AAPL`TSLA;bar1m]
  tab::select from bars where date within dates,sym in syms,time within 14:30:00 21:00:00;
  {![`.eh.tab;();enlist[`sym]!enlist`sym;enlist[x 1]!enlist x 2];}each newp;
  tab
  }










/params:.params strat;
/a1:select from bars where date within dates,time within .params `market_hours,sym in syms;
/
a nice next task for you would be to write a function .eh.run which takes
strat (e.g. `mr1)
dates
syms
bars (e.g. `bar1m)
and for a v0.1.0 it (for strat=`mr1), this function
filters the bars table on the dates and syms that are passed in
to this result set, it dynamically adds the indicator columns as specified in .strat.mr1.indicators
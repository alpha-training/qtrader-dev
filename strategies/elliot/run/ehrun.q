\l /data/alf/polygon/hdb/us_stocks_sip
\l /home/ehutton/qtrader-dev/vendor/qi/ta/ta.q
\d .eh
t1:`ndep xasc update up:0b,ndep:count each depends_on from .ta.inds;
order:();
getOrder:{ / the only purpose of this function is to ensure the varible "order" dictates the correct order for the indicators to be run
  if[0=count remaining:exec indicator from t1 where not up;:0b];
  order::order,ready:except[exec indicator from t1 where 0=ndep;order];
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
/write back test for run 
/params:.params strat;
/a1:select from bars where date within dates,time within .params `market_hours,sym in syms;
/
/if[0<count d:.qi.opts`data; system"l ",d]
if[`data in key cmd:.Q.opt .z.x;system raze"l ",cmd`data];
a nice next task for you would be to write a function .eh.run which takes
strat (e.g. `mr1)
dates
syms
bars (e.g. `bar1m)
and for a v0.1.0 it (for strat=`mr1), this function
filters the bars table on the dates and syms that are passed in
to this result set, it dynamically adds the indicator columns as specified in .strat.mr1.indicators
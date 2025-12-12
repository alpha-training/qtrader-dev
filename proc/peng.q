\e 1
path:((.conf.stack.vars.strats),"/"),/:(.conf.self.strats,\:"/default.json")
{a:.qi.readj each x;a:update `$name,`$syms from a;stratVars::`name xkey a}path;

/ Relative strength index - RSI - ranges from 0-100
u.relativeStrength:{[px;n]
  start:avg(n+1)#px;
  (n#0n),start,{(y+x*(z-1))%z}\[start;(n+1)_px;n]}

/ public
RSI:{[px;n]
  diff:px-prev px;
  rs:u.relativeStrength[diff*diff>0;n]%u.relativeStrength[abs diff*diff<0;n];
  100*rs%1+rs
  }

/open a handle to tp0
upd:insert;
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;system "cd ",1_-10_string first reverse y};
if[.conf.self.subscribe.tp0 like "all";.u.rep .(.ipc.conn`tp0)"(.u.sub[`;`];(`.u `i`L))"]

/ strategy function
peter_strat1:{
    d:stratVars`peter_strat1;
    symsStr:"`","`" sv string (d:stratVars`peter_strat1)`syms;
    if[not `bar1s in tables`;.u.rep .(.ipc.conn`tp0)"(.u.sub[`;",symsStr,"];(::))"];
    t:bar1s;if[0=count bar1s;:`sym`strat xkey .schema.t.Intent]; / get all data for subscribed syms
    t:update rsi:RSI[close;"j"$d`rsi_period] by sym from t;
    t:update enterLong:(not null rsi)&rsi<d`enter_long_rsi by sym from t;
    int:select sym,time from t where enterLong;
    int:update strat:`peter_strat1,tgtpos:"j"$d`position_size,urgency:1.0,info: from int;
    `sym`strat xcols int
    }

/ publish intents
pub_intents:{if[0<>count a:peter_strat1[];.ipc.conn[`net](`intent;a)]}

.event.addHandler[`.z.ts;`pub_intents]
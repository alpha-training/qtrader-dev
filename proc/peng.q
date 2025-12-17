\e 1
path:{.qi.path .paths.conf,`strats,x,`default.json}each `$.conf.stacks.dev1.processes.peng.strats
stratVars:sDicts[;0]!(sDicts:{a:.qi.readj x;a:update `$name,`$syms from a;(a`name;a)}each path)[;1]

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
    if[not (tbl:`$d`sub) in tables`;.u.rep .(.ipc.conn`tp0)"(.u.sub[`;",symsStr,"];(::))"];
    t:get tbl;if[0=count t;:ps::`sym`strat xkey .schema.t.Intent]; / get all data for subscribed syms
    t:update rsi:RSI[close;"j"$d`rsi_period] by sym from t;
    t:update enterLong:(not null rsi)&rsi<d`enter_long_rsi by sym from t;
    int:select sym,time from t where enterLong;
    int:update strat:`peter_strat1,tgtpos:"j"$d`position_size,urgency:1.0,info: from int;
    `sym`strat xcols int
    }

/ publish intents
pub_intents:{if[0<>count a:peter_strat1[];.ipc.conn[`net](`intent;a)]}

.event.addHandler[`.z.ts;`pub_intents]
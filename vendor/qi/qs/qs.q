/ translate qsharpe files into q

\l lib/qi.q
\l vendor/qi/ta/ta.q
.qi.loadcfg[`.params.ta;`:vendor/qi/ta/defaults.params]

\d .qs

F:system"f .ta"
/MF:(F,\:"("),F,\:" ("
HEADERS:string`params`state`indicators`enter`signal_exit`stop_loss`take_profit`time_stop`trailing_stop`exit_policy`execution

/ returns a boolean of where y (at any level of depth) exists in x
find:{$[(t:type x)in 0 99h;raze .z.s[;y]each x;11=abs t;except[(),y?x;count y];()]}
toagg:{last -5!"select ",sv[",";x]," from t"}
dparse:{$[type x;-5!x;.z.s each x]}each   / parse at depth
byds:{x!x}`date`sym
byg:{x!x}1#`G

/ entry function
l:{[strat]
  lparams strat;
  s@:where 0<count each s:read0 p:` sv `:strategies,.qi.ext[strat;".qs"];
  sections:where[s like"[A-z]*"]_s;
  if[count ih:(headers:sections[;0])except HEADERS,'":";'"invalid header(s): ",","sv ih];
  /NS::` sv `.params,strat;
  processSection[strat]'[`$-1_'headers;1_'sections];
  -1"";-1 d:"q).strat.",string strat;
  show get d;
 }

processSection:{[strat;header;body]
  /-1"--- ",string[header], " ---";
  sv[`;`.strat,strat,header]set r:ps[header][strat;body];
  /$[type r;show;-1 each]r;
 }

ps.params:{[strat;x]
  if[count invalid:(p:`$tx:trim x)except 1_key params:.params strat;
    '"Unrecognized params: ",","sv string invalid];
  p#params
  }

ps.indicators:{[strat;x]parse1Definition[strat]each trim x}

ps.enter:{[strat;x]parse1Expression[strat]each trim x}
ps.signal_exit:ps.enter
ps.stop_loss:ps.enter
ps.trailing_stop:ps.enter
ps.take_profit:ps.enter
ps.time_stop:ps.enter
ps.state:{[strat;x] trim x}
ps.exit_policy:ps.state
ps.execution:ps.state

/ e.g. v1 = stdev(close, lookback) - lookback*some_val
parse1Definition:{[strat;x]
  if[not"="~x eq:not[x in .Q.an," "]?1b;'"Indicator definition should be of the form: variable = expression. Instead it is: ",x];
  k:trim eq#x;
  v:parse1Expression[strat]trim(1+eq)_x;
  k,":",v
  }

findWord:{x ss/:{a,x,a:"[^A-z,_,0-9]"}each y}

/ e.g. stdev(close, lookback) - lookback*some_val
parse1Expression:{[strat;x]
  if[count x ss"==";'"Use a single = to check for equality: ",x];
  s:a,x,a:"\001";
  p:1_key pd:.params strat;
  if[count pm:ungroup([]p;loc:1+findWord[s;string p]);
    pm:update n:count each string p from`loc xasc pm;
    a:pm[`loc]_s;
    s:(first[pm`loc]#s),raze{[pd;x;y] .qi.tostr[pd y`p],y[`n]_x}[pd]'[a;pm]];
  s:ssr[s;"--";""];   / TODO - bit hacky
  m:ungroup([]func:F;loc:findWord[s;string F]);
  replaces:parse1Function[s]each m;
  1_-1_s{ssr[x;y 0;y 1]}/replaces
 }

parse1Function:{
  s:(1+i:y`loc)_x;
  sf:string f:y`func;
  fv:.ta.u.fv f;
  if[(::)~proj:.ta.proj y`func;proj:()];
  if[not(b~asc b)&2=count b:distinct s?"()";'sf," is a reserved function in the .ta namespace. Either choose another variable name or call the function with round brackets"];
  if[";"in as:1_first b _s;'"qs arguments should be separated by , not ; (",as,")"];
  args:`$trim","vs as;
  if[fv<>an:count args;
    'sf," expects ",string[fv]," arguments, not ",string[an],": ",(1+s?")")#s];
  if[not(::)~proj:.ta.proj y`func;args:proj,args];
  frm:(1+b 1)#s;
  to:".ta.",sf,"[",sv[";";string args],"]";
  (frm;to)
  }

{
  if[ok:0<count .z.x;
    if[ok:0<count s:.qi.opts`strats;
      ok:0<count STRATS::`$","vs trim s]];
  if[not ok;
    -1"Usage q qs.q -strats [mr1,mr2...]";exit 1];
  }[];

/ load params
lparams:{[strat]
  -1 "Loading params for ",.qi.tostr strat;
  ns:` sv`.params,strat;
  pd:`:strategies/params;
  .qi.loadcfg[ns;` sv pd,`defaults.params];
  if[.qi.exists f:.qi.path pd,.qi.ext[strat;".params"];
    .qi.loadcfg[ns;f]];
 }

/ ---- testing section  ---

.qs.l each STRATS;

run:{[t;d;s;strat]
  sd:.strat strat;
  fdate:$[2=count d;within;in];
  a:select from t where fdate[date;d],sym in s;
  a:update`g#G from a lj 2!update G:i from distinct select date,sym from a;
  a:update I:-1+sums i=i by G from a;
  a:update `g#I from a;
  d:toagg sd`indicators;
  od:group iasc[od]#od:find[;key d]each d;
  a:{![y;();byg;z#x]}[d]/[a;od];
  a:delete date,transactions from{![y;dparse x z;byg;(1#z)!1#1b]}[sd]/[a;key[sd]inter`enter`signal_exit];
  a
  }

\d .

/ 
\l /Users/kieran/data/massive/hdb/us_stocks_sip
r:.qs.run[`bar1m;2025.09.19;`AAPL`JPM;`mr1]
/ translate qsharpe files into q

\l lib/qi.q
\l vendor/qi/qs/fn.q

\d .qs

F:system"f .qs.fn"
/MF:(F,\:"("),F,\:" ("
HEADERS:string`params`state`indicators`enter`signal_exit`stop_loss`take_profit`time_stop`trailing_stop`exit_policy`execution

/ entry function
l:{[p]
  s@:where 0<count each s:read0 p;
  sections:where[s like"[A-z]*"]_s;
  if[count ih:sections[;0]except HEADERS,'":";'"invalid header(s): ",","sv ih];
  processSection each sections; 
 }

processSection:{[x]
  -1"--- ",(a:-1_first x), " ---";
  ps[`$a]1_x;
 }

ps.params:{
  if[count invalid:(p:`$tx:trim x)except 1_key .params;
    '"Unrecognized params: ",","sv string invalid];
  -1 each tx,'"=",'string .params p;-1"";
  }

ps.indicators:{-1 each parse1Definition each trim x;-1"";}

ps.enter:{-1 each parse1Expression each trim x;-1"";}
ps.signal_exit:ps.enter
ps.stop_loss:ps.enter
ps.trailing_stop:ps.enter
ps.take_profit:ps.enter
ps.time_stop:ps.enter
ps.state:{-1 each trim x;-1"";}
ps.exit_policy:ps.state
ps.execution:ps.state

/ e.g. v1 = stdev(close, lookback) - lookback*some_val
parse1Definition:{
  if[not"="~x eq:not[x in .Q.an," "]?1b;'"Indicator definition should be of the form: variable = expression. Instead it is: ",x];
  k:trim eq#x;
  v:parse1Expression trim(1+eq)_x;
  k,":",v
  }

findWord:{x ss/:{a,"]",x,(a:"[^A-z"),",_,0-9]"}each y}

/ e.g. stdev(close, lookback) - lookback*some_val
parse1Expression:{[x]
  if[count x ss"==";'"Use a single = to check for equality: ",x];
  s:a,x,a:"\001";
  p:1_key .params;
  if[count pm:ungroup([]p;loc:1+findWord[s;string p]);
    pm:update n:count each string p from`loc xasc pm;
    a:pm[`loc]_s;
    s:(first[pm`loc]#s),raze{.qi.tostr[.params y`p],y[`n]_x}'[a;pm]];
  s:ssr[s;"--";""];   / TODO - bit hacky
  m:ungroup([]func:F;loc:findWord[s;string F]);
  replaces:parse1Function[s]each m;
  1_-1_s{ssr[x;y 0;y 1]}/replaces
 }

parse1Function:{
  s:(1+i:y`loc)_x;
  sf:string f:y`func;
  if[not(b~asc b)&2=count b:distinct s?"()";'"Opening and closing brackets not found for ",sf," in: ",s];
  if[";"in as:1_first b _s;'"qs arguments should be separated by , not ; (",as,")"];
  args:`$trim","vs as;
  if[(en:.qs.fv f)<>an:count args;
    'sf," expects ",string[en]," arguments, not ",string[an],": ",(1+s?")")#s];
  if[not(::)~proj:.qs.fp y`func;args:proj,args];
  frm:(1+b 1)#s;
  to:".qs.fn.",sf,"[",sv[";";string args],"]";
  (frm;to)
  }

/ load params
lparams:{.qi.loadcfg[`.params;`:strategies/params,x]}

/ ---- testing section  ---

lparams`defaults.params
lparams`mr.params

{
  if[not count .z.x;-1"Usage q qs.q strategy_file";exit 1];
  if[not .qi.exists p:.qi.path .qi.ext["strategies/",first .z.x;".qs"];-1@1_.qi.tostr[p]," not found";exit 1];
  .qs.l p;
 }[];


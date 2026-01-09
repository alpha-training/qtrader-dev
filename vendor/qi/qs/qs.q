/ translate qsharpe files into q

\l lib/qi.q

\d .qs

loadparams:{.qi.loadcfg[`.params;.qi.path(`:strategies/params;x)]}
HEADERS:string`params`state`indicators`enter`signal_exit`stop_loss`take_profit`time_stop`trailing_stop`exit_policy`execution

/ entry function
l:{[p]
  s@:where 0<count each s:read0 p;
  sections:where[s like"[A-z]*"]_s;
  if[count ih:sections[;0]except HEADERS,'":";'"invalid header(s): ",","sv ih];
  processSection each sections;
 }

/ load params
lp:.qi.loadcfg`.params

processSection:{[x]
  -1"processing ",a:-1_first x;
  ps[`$a]1_x;
 }

ps.params:{
  if[count invalid:(p:`$trim x)except 1_key .params;
    '"Unrecognized params: ",","sv string invalid];
  }

/ ---- testing section  ---

lparams:lp`:strategies/params,

lparams`defaults.params
lparams`mr.params

.qs.l`:strategies/mr1.qs
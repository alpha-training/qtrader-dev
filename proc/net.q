/ Order netting

Intent:`sym`strat xkey .schema.t.Intent
Agg:`sym xkey .schema.t.Agg
Req:`sym xkey .schema.t.Req

/ Accepts a table of Intent records
intent:{[x]
  dbg;
  pubsert[`Intent;x];
  a:.tm.upd select from Intent where sym in x`sym;
  agg:select first time,aggpos:sum tgtpos,urgency:tgtpos wavg urgency by sym,strat from a;
  pubsert[`Agg]agg:agg lj 1!select sym,pos from Agg;
  pubsert[`Req]req:select time,sym,size:aggpos-0^pos,urgency,note from agg;
  if[count req:select from req where size<>0;
    .ipc.conn[`om](`req;req)];
 }
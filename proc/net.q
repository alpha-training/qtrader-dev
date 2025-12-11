/ Order netting

Intent:`sym`strat xkey .schema.t.Intent
Agg:`sym xkey .schema.t.Agg
Req:`sym xkey .schema.t.Req

/ Accepts a table of Intent records
intent:{[x]
  pubsert[`Intent;x];
  a:.tm.upd select from Intent where sym in x`sym;
  agg:select first time,aggtgt:sum tgtpos,urgency:tgtpos wavg urgency by sym from a;
  agg:update 0^pos from agg lj 1!select sym,pos from Agg;
  pubsert[`Agg]agg:update req:aggtgt-pos,note:{""}each i from agg;
  pubsert[`Req]rq:select time,sym,size:req,urgency,note from agg;
  if[count rq:select from rq where size<>0;
    .ipc.async[`om](`req;rq)];
 }
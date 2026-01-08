/ Order netting

Intent:`sym`strat xkey .schema.t.Intent
Agg:`sym xkey .schema.t.Agg
Req:`sym xkey .schema.t.Req
StratPosition:`sym`strat xkey .schema.t.StratPosition

/ Accepts a table of Intent records
intent:{[x]
  pubsert[`Intent;x];
  a:.tm.upd select from Intent where sym in x`sym;
  agg:select first time,aggtgt:sum tgtpos,urgency:tgtpos wavg urgency,note:.tr.tonote[strat;tgtpos*urgency]by sym from a;
  agg:update 0^pos from agg lj 1!select sym,pos from Agg;
  pubsert[`Agg]agg:update req:aggtgt-pos from agg;
  pubsert[`Req]rq:select time,sym,size:req,urgency,note from agg;
  if[count rq:select from rq where size<>0;
    .ipc.async[`om](`req;rq)];
 }

/ updates from the om
omupd:{[t;x]
  s:exec distinct sym from x;
  if[count agg:Agg ij 1!select sym,time,pos:position from x;
    agg:update to:"J"$.tr.fromnote each note from agg;
    spos:ungroup select sym,strat:key each to,chg:.tr.allocate'[pos;get each to]from agg;
    spos:update 0^position from spos lj 2!select sym,strat,position from StratPosition;
    pubsert[`StratPosition].tm.upd select sym,strat,position+chg,vwap:0f from spos;
    pubsert[`Agg;agg]];
  }
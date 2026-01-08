/ Order management

Intent:`sym`strat xkey .schema.t.Intent
Agg:`sym xkey .schema.t.Agg

/ Accepts a table of Intent records
intent:{[x]
  pubsert[`Intent;x];
  a:.tm.upd select from Intent where sym in x`sym;
  agg:select first time,aggtgt:sum tgtpos,urgency:tgtpos wavg urgency,note:.tr.tonote[strat;tgtpos*urgency]by sym from a;
  agg:update 0^pos from agg lj 1!select sym,pos from Agg;
  pubsert[`Agg]agg:update req:aggtgt-pos from agg;
 }

initIDs:{[d] ORDER_ID::.conf.orderid_step*7h$d}

genoid:.tr.genid`ORDER_ID
.u.end:{initIDs x+1;}

Req:`sym xkey .schema.t.Req
Order:update `g#sym from`orderid xkey .schema.t.Order
Position:`sym xkey .schema.t.Position

req:{
 / if[null NET;NET::.z.w];
  s:distinct x`sym;
  a:update 0^current from x lj select current:sum side*size by sym from Order where sym in s,active;
  if[not count a:select from(update delta:size-current,side:0Ni from a)where delta<>0;:()];
  a:update side:1i from a where delta>0,current>=0;
  a:update side:-1i from a where delta<0,current<=0;
  sendnew new:select from a where not null side;
  if[count[a]<>count new;sendcancel exec orderid from a where null side];
 }

sendnew:{[x]
  if[not count x;:()];
  now:.z.p;
  .ipc.async[`devbroker](`new;o:.schema.c.Order#update time:now,orderid:genoid i,price:0n,status:`pending,filled:0,created:now,active:1b from x);
  pub[`Order;o];
  }

/ updates from the broker
brupd:{[t;x]
  if[t=`Order;:t upsert x];
  if[t=`Fill;
    a:select position:sum side*size by sym from x; 
    p:update time:.z.p,0^position,0f^vwap from([]sym:distinct x`sym)#Position;
    p+:a];
   / if[not null NET;
   /   neg[NET](`omupd;`Position;p);
    /  pubsert[`Position;p]]];
 }

sendcancels:{[oids] if[count oids;.ipc.async[`devbroker](`cancel;oids)]}

/.om.pc:{[h] if[NET=h;NET::0Ni]}
/.event.addhandler[`.z.pc;`.om.pc]

initIDs .z.d;
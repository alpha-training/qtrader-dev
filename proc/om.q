/ Order management

initIDs:{[d] ORDER_ID::.conf.orderid_step*7h$d}

genid:{[n;x] n set last r:get[n]+$[1=c:count x;1;1+x];r}
genoid:genid`ORDER_ID
.u.end:{initIDs x+1;}

Req:`sym xkey .schema.t.Req
Order:update `g#sym from`orderid xkey .schema.t.Order

req:{
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

sendcancels:{[oids] if[count oids;.ipc.async[`devbroker](`cancel;oids)]}

initIDs .z.d;
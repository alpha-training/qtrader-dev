/ Order management

/ genID:{(1000000*(86400000*7h$`date$p)+7h$`time$p:.z.p)+(1000*.z.i)+x}

ORDER_ID:PARENT_ID:CHILD_ID:0N

initIDs:{[d]
  ORDER_ID::id:.conf.orderid_step*7h$d;
  PARENT_ID::id;
  CHILD_ID::id;
  }

genid:{[n;x] n set last r:get[n]+$[1=c:count x;1;1+x];r}
genoid:genid`ORDER_ID
genpid:genid`PARENT_ID
gencid:genid`CHILD_ID

.u.end:{
  initIDs x+1;
  }

Req:`sym xkey .schema.t.Req
Order:`sym xkey .schema.t.Order
ParentOrder:`sym xkey .schema.t.ParentOrder
ChildOrder:update `g#sym from`childid xkey .schema.t.ChildOrder

req:{
  s:x`sym;
  a:update 0^osize from x lj select osize:sum side*size by sym from Order where status in`NEW`SENT`PARTIAL;
  if[count imm:select from a where urgency>.conf.immediate_urgency;   / all are immediate for now
    dbg;
    / Add to Order
    / Add to ChildOrder (broker specific)
    ];
 }

/ x is a row in the ParentOrder table
createChildOrders:{[x]  


 }

initIDs .z.d;
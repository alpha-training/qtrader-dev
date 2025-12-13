/ Order management

ORDER_ID:7h$.z.p
initIDs:{
  .log.info"Init ids to ",string id:.env.DAILY_ID_STEP*7h$x;
  ORDER_ID::id;
  PARENT_ID::id;
  CHILD:ID::id;
  }

.u.end:{initIDs x+1}

Req:`sym xkey .schema.t.Req
Order:`sym xkey .schema.t.Order

req:{
  dbg;
 
 
 }

initIDs .z.d;
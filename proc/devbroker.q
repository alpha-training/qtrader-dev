OM:0Ni
genfillid:.tr.genid`FILL_ID
initIDs:{FILL_ID::.conf.orderid_step*7h$.z.d}
updOMHandle:{if[OM<>h:.z.w;OM::h]}
Order:`orderid xkey .schema.t.Order
new:{updOMHandle`;`Order upsert x;}
cancel:{[oids] updOMHandle`; pubsert[`Order]update status:`cancelled,active:0b from select from Order where orderid in oids,active;}

toOM:{[t;x] if[not null OM;if[count x;neg[OM](`brupd;t;x)]]}

check:{
  if[0=count o:select from Order where active;:()];
  o:update time:.z.p,fill:0,changed:0b from o;
  o:update fill:rand each 1+size-filled from o where active,status<>`pending,{rand 01b}each i;
  o:update filled+fill,changed:1b from o where fill>0;
  o:update status:`partialfill from o where fill>0,size>filled;
  o:update status:`filled,active:0b from o where fill>0,size=filled;
  o:update status:`new,changed:1b from o where status=`pending;
  pubsert[`Order;ro:delete fill,changed from select from o where changed];
  toOM[`Order;ro];
  if[count fo:select time,sym,fillid:genfillid i,orderid,side,size:fill,price from o where fill>0;
    toOM[`Fill;fo];
    pub[`Fill;fo]];
 }

.db.pc:{[h] if[h=OM;OM::0Ni;delete from`Order]}


.event.addhandler[`.z.pc;`.db.pc]
initIDs`;
.cron.add[`check;0Np;00:00:01];
.cron.add[`initIDs;"p"$.z.d+1;1D];

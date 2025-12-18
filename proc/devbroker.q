OM:0Ni

Order:`orderid xkey .schema.t.Order
new:`Order upsert
cancel:{[oids] pubsert[`Order]update status:`cancelled,active:0b from select from Order where orderid in oids,active;}

check:{
  if[0=count o:select from Order where active;:()];
  o:update time:.z.p,fill:0,changed:0b from o;
  o:update fill:rand each 1+size-filled from o where active,status<>`pending,{rand 01b}each i;
  o:update filled+fill,changed:1b from o where fill>0;
  o:update status:`partialfill from o where fill>0,size>filled;
  o:update status:`filled,active:0b from o where fill>0,size=filled;
  o:update status:`new,changed:1b from o where status=`pending;
  pubsert[`Order;delete fill,changed from select from o where changed];
 }

.db.pc:{[h] if[h=OM;OM::0Ni;delete from`Order]}

.cron.add[`check;0Np;00:00:01]
.event.addhandler[`.z.pc;`.db.pc]
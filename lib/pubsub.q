/ Publish & subcribe utilities

pubx:{[tp;t;x] .ipc.async[tp](`.u.upd;t;get flip $[-12=type first first a:$[98=type x;x;0!x];a;.schema.c[t]#a]);}
pub:pubx .qi.tosym .conf.system_tp
pubsert:{[t;x] 
  if[not count x;:()];
  t upsert x;
  pub[t;x];}
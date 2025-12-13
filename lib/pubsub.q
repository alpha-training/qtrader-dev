/ Publish & subcribe utilities

pubx:{[tp;t;x] .ipc.async[tp](`.u.upd;t;get flip x);}
pub:pubx .conf.system_tp
pubsert:{[t;x] upsert[t;x];if[-12<>type first first a:$[98=type x;x;0!x];a:.schema.c[t]#a];pub[t;a]}
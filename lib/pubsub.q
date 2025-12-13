pub:{[t;x] .ipc.async[.conf.system_tp](`.u.upd;t;get flip x);}
pubsert:{[t;x] upsert[t;x];if[-12<>type first first a:$[98=type x;x;0!x];a:.schema.c[t]#a];pub[t;a]}
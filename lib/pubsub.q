.qi.env[`SYSTEM_TP;`tp0;`$];

pub:{[t;x] .ipc.async[.env.SYSTEM_TP](`.u.upd;t;get flip x);}
pubsert:{[t;x] upsert[t;x];pub[t;x]}
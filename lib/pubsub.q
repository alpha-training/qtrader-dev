.qi.env[`SYSTEM_TP;`tp0;`$];

pub:{[t;x] neg[.ipc.conn .env.SYSTEM_TP](`.u.upd;t;get flip x);}
pubsert:{[t;x] upsert[t;x];pub[t;x]}
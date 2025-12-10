.pubsub.TP:.qi.env[`TRADING_TP;`tp0;::]

pub:{[t;x] neg[.ipc.conn .pubsub.TP](`.u.upd;t;get flip x);}
pubsert:{upsert[t;x];pub[t;x]}
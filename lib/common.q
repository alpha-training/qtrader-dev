
\l lib/qi.q

.qi.use`log
.qi.use`ipc
.qi.use`cron

\l lib/tm.q
\l lib/os.q
\l lib/conf.q
\l lib/schema.q
\l lib/pubsub.q

if[.conf.proc<>`c2;system"l lib/c3.q"]
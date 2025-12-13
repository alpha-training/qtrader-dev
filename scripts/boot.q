\l lib/qi.q
\l lib/tm.q
\l lib/common.q
\l lib/conf.q
\l lib/os.q
\l lib/schema.q
\l lib/pubsub.q

if[.conf.proc<>`c2;system"l lib/c3.q"]

.qi.loadf` sv`:proc,.conf.proc;
if[not system"t";system"t ",.qi.tostr .conf.qtimer]
if[not system"p";system"p ",.qi.tostr .conf.self.port];
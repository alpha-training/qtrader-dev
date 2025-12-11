\l lib/qi.q
\l lib/tm.q
\l lib/common.q
\l lib/env.q
\l lib/conf.q
\l lib/os.q
\l lib/schema.q
\l lib/pubsub.q

if[.conf.self.proc<>`c2;system"l lib/c3.q"]

startProcess:{
    confProcs:.conf.procs`$.qi.opts`name;
    system"p ",string confProcs`port;
    system"l proc/",string[confProcs`proc],".q";
 }

if[not system"t";system"t ",.env.QTIMER]

startProcess[]
/
if[""~procName:.qi.opts`name;0N!"missing -name in command line argument!";exit 1];
\l lib/qi.q
\l lib/ts.q
\l lib/common.q
\l lib/env.q
\l lib/conf.q
\l lib/schema.q
\l lib/pubsub.q

.qi.env[`STACK;`dev1;`$]
.conf.loadstack .env.STACK^`$.qi.opts`stack
.conf.checkself[]
\l lib/os.q
\l lib/c3.q

if[.conf.self.proc<>`c2;system"l lib/c3.q"]

startProcess:{
    confProcs:.conf.procs`$.qi.opts`name;
    system"p ",string confProcs`port;
    system"l proc/",string[confProcs`proc],".q";
 }
if[not system"t";system"t 1000"]

startProcess[]
/
if[""~procName:.qi.opts`name;0N!"missing -name in command line argument!";exit 1];
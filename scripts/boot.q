\l lib/qi.q
\l lib/ts.q
\l lib/os.q
\l lib/common.q
\l lib/env.q
\l lib/conf.q
\l lib/schema.q
\l lib/pubsub.q

.conf.loadstack`dev1

startProcess:{
    confProcs:.conf.procs`$.qi.opts`name;
    system"p ",string confProcs`port;
    system"l proc/",string[confProcs`proc],".q";
 }
startProcess[]


/
if[""~procName:.qi.opts`name;0N!"missing -name in command line argument!";exit 1];
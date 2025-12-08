\l lib/qi.q
\l lib/common.q
\l lib/env.q
\l lib/conf.q
\l lib/schema.q

.conf.loadstack`dev1

startProcess:{
    if[""~procName:.qi.opts`name;0N!"missing -name in command line argument!";exit 1];
    if[not (`$procName) in exec name from .conf.procs;0N!"ERROR: Process ",procName," not found in stack configuration.";exit 1];
    confProcs:.conf.procs[`$procName];
    system"p ",string confProcs`port;
    system"l proc/",string[confProcs`proc],".q";
 }
startProcess[]
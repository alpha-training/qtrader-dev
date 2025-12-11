.qi.include`event

\d .ipc

TIMEOUT:1000

conns:1!flip`name`proc`port`handle`pid`lastHeartbeat`error!"ssiiip*"$\:()
conn:sync:{[name] 
  if[null(e:conns name)`proc;'"Unrecognized process: ",string name];
  if[not null h:e`handle;:h];
  conns[name]:e,:`handle`error!tryConnect e`port;
  e`handle}

async:{[name] $[null h:sync name;h;neg h]}

tryConnect:{[port] 1_.qi.try1[hopen;("::",.qi.tostr port;TIMEOUT);0Ni]}
disconnect:{update handle:0Ni,pid:0Ni,lastHeartbeat:0Np from`.ipc.conns where handle=x}

\d .

.event.addHandler[`.z.pc;`.ipc.disconnect]

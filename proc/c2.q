\d .c2

tailrows:"J"$.conf.stack.vars`TAIL_ROWS
procs:1!select name,proc,port,handle,pid:0Ni,status:`down,used:0N,heap:0N,logfile:`,lastheartbeat:0Np from .ipc.conns where proc<>`c2;
notfound:{[pname] string[pname]," process not found"}
entry:{[pname] $[null(e::procs pname)`proc;();e]}

start:{[pname]
  p:first exec port from procs where name=pname;
  .os.startproc["scripts/boot.q -name ",string[pname]," -p ",string p;.conf.stack.vars.data,"/",string[pname],".log"];
  .c2.procs[pname;`status`logfile]:(`up;`$string[pname],".log")
 }
startall:{start each exec name from .conf.procs}

kill:{[pname]
  .os.kill[first exec pid from procs where name=pname];
  update status:`down from procs where name=pname;
 }
killall:{kill each exec name except `c2 from procs where status~`up}

down:{[pname]
 if[()~e:procs pname;:".c2.down: ",string[pname]," not found"];sname:string pname;
 if[null h:e`handle;:".c2.down ",sname," handle is null"];
 if[not first r:.qi.try[{neg[x]y};(h;(`.c3.down;`host`port`args!(.z.h;system"p";" "sv .z.x)));::];
 .log.error".c2.down ",sname," ",r 2];
 .c2.procs[pname;`used`heap`pid]:(0N;0N;0N)
 }
downall:{down each exec name except`c2 from procs where status~`up}

tail:{[pname]
  file:first exec logfile from procs where name=pname;
  if[not .qi.isfile` sv(`:logs/proclogs;file);0N!"error! logfile doe not exist";:()];
  .os.tail[file;tailrows]
  }

heartbeat:{[pname;info]
  if[not pname in exec name from .conf.procs;:.log.warn".c2.heartbeat - unrecognized process name: ",string pname];
  update 
    handle:.z.w,
    pid:info`pid,
    used:info`used,
    heap:info`heap,
    status:`up,
    lastheartbeat:.z.p
  from`.c2.procs where name=pname;
 }

pc:{[h] update handle:0Ni,pid:0Ni,status:`down,used:0N,heap:0N from `.c2.procs where handle=h}

check:{
  update status:`busy from `.c2.procs where handle>0,lastheartbeat<.z.p-.conf.me.BUSY_PERIOD;
 }

.event.addHandler[`.z.pc;`.c2.pc]
.cron.add[`.c2.check;0Np;00:00:01]

\d .




/
tailx:{[pname;n]
  if[()~e:entry pname;:notfound pname];
  $[.qi.isfile lf:e`log;system"tail -n ",string[n]," ",lf;"Log file not found ",lf]
 }

tail:{[pname] tailx[pname;TAIL_ROWS]}

down:{[pname]
  if[()~e:entry pname;:notfound pname];sname:string pname;
  if[null h:e`handle;:".c2.down ",sname," handle is null"];
  if[not first r:.qi.try[neg h;(`.c3.down;`host`port`.z.x!(.z.h;system"p";" "sv .z.x));::];
    .log.error".c2.down ",sname," ",r 2];
 }

killx:{[pname;n]
  if[()~e:entry pname;:notfound pname];
  if[null e`pid;".c2.killx ",string[pname]," pid is null"];
  system"kill -",string[n]," ",string e`pid
 }

interrupt:killx[;2]
kill:killx[;9]
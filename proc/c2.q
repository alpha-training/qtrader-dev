/ Command & Control
\l lib/qi.q
\l lib/os.q
\l lib/common.q
\l lib/env.q
\l lib/conf.q
\l lib/schema.q

.conf.loadstack`dev1

W:.z.o like"w*"     / true for windows
/.ipc.init[];

\d .c2

TAIL_ROWS:10

procs:update pid:0Ni,status:`down,used:0N,heap:0N,logfile:` from .ipc.conns

notfound:{[pname] string[pname]," process not found"}
entry:{[pname] $[null(e:procs pname)`proc;();e]}

heartbeat:{[pname;info]
  if[not pname in exec name from .conf.procs;:.log.warn".c2.heartbeat - unrecognized process name: ",string pname];
  update 
    handle:.z.w,
    pid:.z.i,
    used:.Q.w[]`used,
    heap:.Q.w[]`heap,
    status:`up,
    lastHeartbeat:.z.p
  from`.c2.procs where name=pname;
  /procs[pname],:(`handle`pid`lastheartbeat`status!(.z.w;info`pid;.z.p;`up)),select used,heap from info;
 }

up:{[pname]

 }

down:{[pname]
  if[()~e:entry pname;:notfound pname];sname:string pname;
  if[null h:e`handle;:".c2.down ",sname," handle is null"];
  if[not first r:.qi.try[neg h;(`.c3.down;`host`port`.z.x!(.z.h;system"p";" "sv .z.x));::];
    .log.error".c2.down ",spname," ",r 2];
 }

killx:{[pname;n]
  if[()~e:entry pname;:notfound pname];
  if[null e`pid;".c2.killx ",string[pname]," pid is null"];
  system"kill -",string[n]," ",string e`pid
 }

interrupt:killx[;2]
kill:killx[;9]
/
tailx:{[pname;n]
  if[()~e:entry pname;:notfound pname];
  $[.qi.isfile lf:e`log;system"tail -n ",string[n]," ",lf;"Log file not found ",lf]
 }

tail:{[pname] tailx[pname;TAIL_ROWS]}
\
c3.init:{[pname;hostport]
  if[`c3 in key`;:()];
  .qi.use`c3;
  .c3.init[pname;hostport];
  }


start:{[pname]
  .os.startproc["scripts/boot.q -name ",string[pname]," -p ",string p;.conf.stack.vars.data,"/",string[pname],".log"];
  update status:`up,logfile:(`$string[pname],".log")from `procs where name=pname;
 }

startall:{start each exec name from .conf.procs}

pkill:{[pname]
  .os.kill[first exec pid from procs where name=pname];
  update status:`down from procs where name=pname;
 }

pkillall:{pkill each exec name from .ipc.conns}

tail:{[pname]
  system"tail -n ",string[TAIL_ROWS]," ",string[first exec logfile from procs where name=pname]
  }
\d .

start:{[pname] .os.startproc["scripts\\boot.q -name ",string[pname]," -p ",string p;.conf.stack.vars.data,"/",string[pname],".log"]}
/
start:{[fileargs;pname]
    p:first exec port from .conf.procs where name=pname;
    if[W;system"start /B q scripts\\boot.q -name ",string[pname]," -p ",string[p]," > logs\\",string[pname],".log 2>&1 &";
      update status:`up,logfile:"log/",string[pname],".log" where name=pname from procs;
      :()];
    QHOME:getenv`QHOME;
    system"nohup ",QHOME,"/l64/q scripts/boot.q -name ",string[pname]," -p ",string[p]," < /dev/null >> data/dev1/proclogs/",string[pname],".log 2>&1 &";
    update status:`up,logfile:(`$"logs/",string[pname],".log")from `procs where name=pname;
  }
\
/
stop:{[pname]
    PID:first exec pid from .ipc.conns where name=pname;
    system"kill -9 ",string pid;
    update status:`down from procs where name=pname
 }
\
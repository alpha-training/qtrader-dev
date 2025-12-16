\l lib/api.q

\d .c2

conns:1!select name,proc,port,handle,pid:0Ni,status:`down,used:0N,heap:0N,logfile:`,lastheartbeat:0Np from .ipc.conns where proc<>`c2;
notfound:{[pname] string[pname]," process not found"}
getprocess:{[pname] $[null(pr::conns pname)`proc;();pr]}

up:{[pname]
  sname:string pname;
  if[()~x:getprocess pname;'".c2.up: ",sname," not found"];
  .os.startproc["scripts/boot.q -name ",string[pname]," -p ",string x`port;logfile:.qi.spath(.conf.processlogs;sname,".log")];
  .c2.conns[pname;`status`logfile]:(`up;hsym`$logfile)
 }

upall:{up each exec name from .c2.conns}

kill:{[pname]
  .os.kill[first exec pid from conns where name=pname];
  update status:`down from conns where name=pname;
 }

killall:{kill each exec name except `c2 from conns where status~`up}

down:{[pname]
 sname:string pname;
 if[()~x:getprocess pname;'".c2.down: ",sname," not found"];
 if[null h:x`handle;:()];
 .log.info".c2.down - Shutting down ",sname;
 if[not first r:.qi.try[{neg[x]y};(h;(`.c3.down;`host`port`args!(.z.h;system"p";" "sv .z.x)));::];
   .log.error".c2.down ",sname," ",r 2];
 .c2.conns[pname;`used`heap`pid]:(0N;0N;0Ni)
 }

downall:{down each exec name from`.c2.conns where status in`up`busy}

tail:{[pname]
  file:first exec logfile from conns where name=pname;
  if[not .qi.isfile` sv(`:logs/proclogs;file);0N!"error! logfile doe not exist";:()];
  .os.tail[file;.conf.tailrows]
  }

heartbeat:{[pname;info]
  if[not pname in exec name from .c2.conns;:.log.warn".c2.heartbeat - unrecognized process name: ",string pname];
  update handle:.z.w,pid:info`pid,used:info`used,heap:info`heap,status:`up,lastheartbeat:.z.p
  from`.c2.conns where name=pname;
 }

pc:{[h] update handle:0Ni,pid:0Ni,status:`down,used:0N,heap:0N from`.c2.conns where handle=h}

updAPI:{
  .api.pub[`processes;0!.c2.conns];
 }

check:{
  update status:`busy from `.c2.conns where handle>0,lastheartbeat<.z.p-.conf.busyperiod;
  updAPI[];
  }

{
  startproc::$[.os.W;
            {[fileArgs;logfile]system"start /B cmd /c ",.conf.qbin," ",ssr[fileArgs;"/";"\\"]," >> ",ssr[logfile;"/";"\\"]," 2>&1"};
            {[fileArgs;logfile]system"nohup ",.conf.qbin," ",fileArgs," < /dev/null >> ",logfile,"  2>&1 &"}];
  kill::$[.os.W;
        {[pid]system"taskkill /",string[pid]," /F"};
        {[pid]system"kill ",string pid}];

  tail::$[.os.W;
        {[file;n]system"cmd /C powershell -Command Get-Content ",ssr[file;"/";"\\"]," -Tail ",string n};
        {[file;n]system"tail -n ",string[n]," ",file}];
  }[]

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
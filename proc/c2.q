/ Command & control

\l lib/api.q

\d .c2

conns:1!select name,proc,port,handle,pid:0Ni,status:`down,used:0N,heap:0N,lastheartbeat:0Np from .ipc.conns where proc<>`c2;

logfile:{[name] .qi.spath(.conf.processlogs;` sv name,`log)}

getprocess:{[pname] $[null(x:conns pname)`proc;();x]}

up:{[pname]
  sname:string pname;
  if[()~x:getprocess pname;'".c2.up: ",sname," not found"];
  os.startproc["qtrader.q -name ",sname;logfile pname];
 }

upall:{up each exec name from .c2.conns where status=`down}

kill:{[pname] if[not null pid:conns[pname]`pid;os.kill pid]}
killall:{kill each exec name from conns where not null pid}

down:{[pname]
 sname:string pname;
 if[()~x:getprocess pname;'".c2.down: ",sname," not found"];
 if[null h:x`handle;:()];
 .log.info".c2.down ",sname;
 if[not first r:.qi.try[{neg[x]y};(h;(`.c3.down;`host`port`args!(.z.h;system"p";" "sv .z.x)));::];
   .log.error".c2.down ",sname," ",r 2];
 }

downall:{down each exec name from .c2.conns where status in`up`busy}

tail:{[pname]
  if[()~x:getprocess pname;'".c2.tail: ",string[pname]," not found"];
  if[not .qi.isfile p:logfile pname;:"Log file not found. Expected at ",p];
  os.tail[p;.conf.tailrows]
  }

heartbeat:{[pname;info]
  if[()~x:getprocess pname;'".c2.heartbeat: ",string[pname]," not found"];
  .c2.conns[pname],:select handle:.z.w,pid,used,heap,status:`up,lastheartbeat:.z.p from info;
 }

pc:{[h] update handle:0Ni,pid:0Ni,status:`down,used:0N,heap:0N from`.c2.conns where handle=h}

updAPI:{.api.pub[`processes;0!.c2.conns];}

check:{
  update status:`busy from `.c2.conns where handle>0,lastheartbeat<.z.p-.conf.busyperiod;
  updAPI[];
  }

{
  os.startproc:$[.os.W;
            {[fileArgs;logfile]system"start /B cmd /c ",.conf.qbin," ",.os.towin[fileArgs]," >> ",ssr[logfile;"/";"\\"]," 2>&1"};
            {[fileArgs;logfile]system"nohup ",.conf.qbin," ",fileArgs," < /dev/null >> ",logfile,"  2>&1 &"}];

  os.kill:$[.os.W;
        {[pid]system"taskkill /",string[pid]," /F"};
        {[pid]system"kill ",string pid}];

  os.tail:$[.os.W;
        {[file;n]system"cmd /C powershell -Command Get-Content ",.os.towin[file]," -Tail ",.qi.tostr n};
        {[file;n]system"tail -n ",.qi.tostr[n]," ",file}];
  }[]

.event.addHandler[`.z.pc;`.c2.pc]
.cron.add[`.c2.check;0Np;00:00:01]
`:api/local_base_port.txt 0:enlist .qi.tostr .conf.base_port;

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
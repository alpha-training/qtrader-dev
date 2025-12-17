/ Command & control

\l lib/api.q

\d .c2

conns:1!select name,proc,port,handle,pid:0Ni,status:`down,used:0N,heap:0N,lastheartbeat:0Np,attempts:0,goal:`,lastaction:`,lasttime:0Np from .ipc.conns where proc<>`c2;

getprocess:{[pname] $[null(x:conns pname)`proc;();x]}
getlog:{[name] .qi.spath(.conf.processlogs;` sv name,`log)}

/ process control functions
p.up:{[pname;x]
  conns[pname;`goal]:`up;
  if[.conf.max_start_attempts>conns[pname]`attempts;
    conns[pname],:select attempts:1+0^attempts,lastaction:`up,lasttime:.z.p from x;
    os.startproc["qtrader.q -name ",string pname;getlog pname]];
 }

p.down:{[pname;x]
 conns[pname],:`goal`attempts!(`down;0);
 if[null h:x`handle;:()];
 .log.info".c2.down ",sname:string pname;
 conns[pname],:select lastaction:`down,lasttime:.z.p from x;
 if[not first r:.qi.try[{neg[x]y};(h;(`.c3.down;`host`port`args!(.z.h;system"p";" "sv .z.x)));::];
   .log.error".c2.down ",sname," ",r 2];
 }

p.tail:{[pname;x]
  if[not .qi.isfile p:getlog pname;:"No log file found at ",p];
  os.tail[p;.conf.tailrows]
  }

p.kill:{[pname;x] if[not null pid:x`pid;os.kill pid]}
p.heartbeat:{[pname;x;info] .c2.conns[pname],:select handle:.z.w,pid,used,heap,status:`up,lastheartbeat:.z.p,attempts:0N from info;}

/ thin wrappers around functions in .c2.p (to check if process exists)
fprocx:{[f;pname] $[()~x:getprocess pname;'".c2.",string[f],": ",string[pname]," not found in .c2.conns";p[f][pname;x]]}
fprocxy:{[f;pname;y] $[()~x:getprocess pname;'".c2.",string[f],": ",string[pname]," not found in .c2.conns";p[f][pname;x;y]]}
{x set $[2=count get[p x]1;fprocx;fprocxy]x}each 1_key p;

/ [f]all functions
upall:{up each exec name from .c2.conns where status=`down;}
downall:{down each exec name from .c2.conns where status in`up`busy}
killall:{kill each exec name from conns where not null pid}

/ event functions
pc:{[h] update handle:0Ni,pid:0Ni,status:`down,used:0N,heap:0N,attempts:0N from`.c2.conns where handle=h}
updAPI:{.api.pub[`processes;0!.c2.conns];}
check:{
  update status:`busy from `.c2.conns where handle>0,lastheartbeat<.z.p-.conf.busyperiod;
  updAPI[];
  }

/ initialisation
{
  os.startproc:$[.os.W;
    {[fileArgs;logfile]system"start /B cmd /c ",.conf.qbin," ",.os.towin[fileArgs]," >> ",.os.towin[logfile]," 2>&1"};

    {[fileArgs;logfile]
      system"mkdir -p ",.qi.spath .conf.processlogs;
      system"nohup ",.conf.qbin," ",fileArgs," < /dev/null >> ",logfile,"  2>&1 &"}];

  os.kill:$[.os.W;
    {[pid]system"taskkill /",string[pid]," /F"};
    {[pid]system"kill ",string pid}];

  os.tail:$[.os.W;
    {[logfile;n]system"cmd /C powershell -Command Get-Content ",.os.towin[logfile]," -Tail ",.qi.tostr n};
    {[logfile;n]system"tail -n ",.qi.tostr[n]," ",logfile}];
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
/ Operating system abstraction

\d .os

W:.z.o like"w*"

startproc:{[fileArgs;logfile]  / do fileArgs go in as / or \ same  with logfile as string or symbol?
    qpath:.conf.stack.vars.qbin;
    $[W;
        system"Start-Process -FilePath ",qpath," -ArgumentList ",fileArgs," -RedirectStandardOutput ",logfile," -RedirectStandardError ",logfile," -WindowStyle Hidden";
        system"nohup ",qpath," ",fileArgs," < /dev/null >> ",logfile,"  2>&1 &"]
    }

kill:{[pid] $[W;system"taskkill /",string[pid]," /F";system"kill ",string pid]}
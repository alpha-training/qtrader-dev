/ Operating system abstraction

\d .os
W:.z.o like"w*"
QBIN:.conf.stack.vars.qbin


startproc:$[W;
            {[fileArgs;logfile] system"start /B cmd /c ",QBIN," ",fileArgs," >> ",logfile," 2>&1"};
            {[fileArgs;logfile] system"nohup ",QBIN," ",fileArgs," < /dev/null >> ",logfile,"  2>&1 &"}
            ]       
kill:$[W;
        {[pid] system"taskkill /",string[pid]," /F"};
        {[pid] system"kill ",string pid}
        ]



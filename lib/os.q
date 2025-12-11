/ Operating system abstraction

\d .os
W:.z.o like"w*"
QBIN:.conf.stack.vars.qbin


startproc:$[W;
            {[fileArgs;logfile]system"start /B cmd /c ",QBIN," ",ssr[fileArgs;"/";"\\"]," >> ",ssr[logfile;"/";"\\"]," 2>&1"};
            {[fileArgs;logfile]system"nohup ",QBIN," ",fileArgs," < /dev/null >> ",logfile,"  2>&1 &"}
            ]

kill:$[W;
        {[pid]system"taskkill /",string[pid]," /F"};
        {[pid]system"kill ",string pid}
        ]

tail:$[W;
        {[file;n]system"cmd /C powershell -Command Get-Content ",ssr[file;"/";"\\"]," -Tail ",string n};
        {[file;n]system"tail -n ",string[n]," ",file}
        ]
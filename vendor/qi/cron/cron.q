.qi.use`event

\d .cron

jobs:1!flip`jobid`func`period`lastRun`nextRun`error!"jsnpp*"$\:()
add:{[func;start;period] `.cron.jobs upsert(JOBID+:1;func;p;0Np;start|start+p:0Wn^"n"$period;"");}
run1:{[job;now] e:jobs job;r:.qi.try1[get e`func;now;::];jobs[job]:e,`lastRun`nextRun`error!(now;$[0Wn=p:e`period;0Wp;now+p];r 2)}
run:{run1[;x]each exec jobid from jobs where nextRun<x;}

\d .

.event.addHandler[`.z.ts;`.cron.run]
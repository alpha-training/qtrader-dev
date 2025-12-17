/ Command & control client

\d .c3

C2:0Ni
down:{[info] .log.info ".c3.down called by: ",.j.j info;exit 0}
heartbeat:{if[not null C2;neg[C2](`.c2.heartbeat;.conf.name;`pid`used`heap!(.z.i;w`used;(w:.Q.w`)`heap))]}
c2reconnect:{if[null C2;if[not null port:.conf.base_port;if[not null h:@[hopen;port;0Ni];C2::h;heartbeat`]]]}
pc:{[h] if[h=C2;C2::0Ni]}

.event.addHandler[`.z.pc;`.c3.pc]
.cron.add[`.c3.c2reconnect;0Np;00:00:01];
.cron.add[`.c3.heartbeat;0Np;00:00:10];
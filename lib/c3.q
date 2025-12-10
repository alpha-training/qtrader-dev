/ Command & Control Client

\d .c3

C2HOSTPORT:0N
C2HANDLE:0Ni
PNAME:`

pc:{[h] if[h=C2HANDLE;C2HANDLE::0Ni]}

down:{[senderinfo] .log.quit(".c3.down called";senderinfo)}

heartbeat:{if[not null h:C2HANDLE;neg[h](`.c2.heartbeat;PNAME;select used, heapfrom .Q.w`)]}

c2reconnect:{
  if[null[C2HANDLE]&not null C2HOSTPORT;
    if[not null h:@[hopen;C2HOSTPORT;0Ni];
      .log.info"Reconnected to c2";C2HANDLE::h]];
  }

init:{[pname;c2hostort]
  PNAME::pname;
  C2HOSTPORT::c2hostport;
  .cron.add[`.z.ts;`.c3.heartbeat;00:00:10];
 }

.event.addHandler[`.z.pc;`.c3.pc]
.cron.add[`.z.ts;`.c3.c2reconnect;00:00:10];
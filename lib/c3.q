/ Command & control client

\d .c3

C2HANDLE:0Ni

pc:{[h] if[h=C2HANDLE;C2HANDLE::0Ni]}

/ down:{[senderinfo] .log.quit(".c3.down called";senderinfo)}
down:{[senderinfo] .log.quit ".c3.down called by: ", .j.j senderinfo;}

/heartbeat:{if[not null h:C2HANDLE;neg[h](`.c2.heartbeat;.conf.self.name;`pid`used`heap!(.z.i;.Q.w[]`used;.Q.w[]`heap))]}
heartbeat:{
  if[null h:.ipc.conn`c2;:()];
  neg[h](`.c2.heartbeat;.conf.self.name;`pid`used`heap!(.z.i;.Q.w[]`used;.Q.w[]`heap))
    }

c2reconnect:{
  if[null C2HANDLE;
    if[not not null port:.conf.c2_port;
      if[not null h:@[hopen;port;0Ni];
        .log.info"Reconnected to c2";
        C2HANDLE::h]]];
  }

.event.addHandler[`.z.pc;`.c3.pc]
.cron.add[`.c3.c2reconnect;0Np;00:00:10];
.cron.add[`.c3.heartbeat;0Np;00:00:10];
\d .conf

.paths.conf:` sv .env.QT_HOME,`conf

loadstack:{[stackname]
  .paths.stack:` sv .paths.conf,`stacks,stackname;
  stack::r:((1#`name)!1#stackname),.qi.parsej .paths.stack,`procs.json;
  c2_port::"J"$r[`vars]`c2_port;
  def:`proc`port_offset`taskset`args`depends_on`port!(`;0N;"";();();0N);
  procs:([]name:key v)!key[def]#/:def,/:get v:r`processes;
  .conf.procs:update`$proc,7h$port_offset,`$depends_on,7h$port from procs;
  update port:port_offset+.conf.c2_port from`.conf.procs where null port,not null port_offset;
  `.ipc.conns upsert select name,proc,port from .conf.procs;
  if[not`name in key .qi.opts;:(::)];
  if[not(n:`$.qi.opts`name)in key v;'"Unrecognized process name: ",string n];
  self::((1#`name)!1#n),.conf.procs[n],key[def]_v n;
 }

checkself:{
  if[count d:self`depends_on;
    if[count w:where null d!.ipc.conn each d;
      .log.fatal"Could not connect to ",","sv string w]];
 }

pc:{if[count d:exec name from .ipc.conns where name in .conf.self.depends_on,null handle;.log.fatal"Lost connection to ",","sv string d]}

.event.addHandler[`.z.pc;`.conf.pc];
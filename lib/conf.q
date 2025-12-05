\d .conf

paths.conf:` sv .env.QT_HOME,`conf

loadstack:{[stackname]
  r:.qi.parsej paths.conf,`stacks,stackname,`procs.json;
  dbg;
  base::7h$r`base_port;
  def:`proc`cmd`port_offset`taskset`args`depends_on`port!(`;"";0N;"";();();0N);
  procs:([]name:key v)!key[def]#/:def,/:get v:r`processes;
  .conf.procs:update`$proc,7h$port_offset,`$depends_on,7h$port from procs;
  update port:port_offset+.conf.base from`.conf.procs where null port,not null port_offset;
  `.ipc.conns upsert select name,proc,port from .conf.procs;
 }
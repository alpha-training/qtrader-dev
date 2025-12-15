
.paths.conf:`:conf    / TODO - perhaps change later

\d .conf

name:proc:`

expand:{
  if[0=count x;:x];
  if[(t:type x)in 0 98 99h;:.z.s each x];
  if[t<>10;:x];
  if[not sum d:x="$";:x];
  a:where[d|not x in .Q.an]_x;
  raze@[a;where a like"$*";{$[(::)~r:.conf`$1_x;"MISSING";.qi.tostr r]}]
 }

u.load1conf:{[p]
  if[not .qi.exists p;:()];
  { a:expand x`v;
    r:$[null t:x`typ;.qi.infer2;upper[t]$]a;
    sv[`;`.conf,x`k]set r}each flip`k`v`typ!("S*C";",")0:p;
  }

u.loadconf:{
  f:{u.load1conf .qi.path .paths.conf,x};
  f`global.csv;
  f`local.csv;
  f (sp:`stacks,.conf.stackname),`stack.csv;
  if[not`qbin in key .conf;.conf.qbin:.qi.path(getenv`QHOME;.z.o;`q)];
  if[not .qi.exists qb:.conf.qbin;
    .log.fatal".conf.qbin - file not found at ",.qi.tostr[qb],"\n\nFix: create or edit ",
    .qi.spath[.paths.conf,`local.csv]," with a valid entry:\nqbin=/path/to/qhome/",string[.z.o],"/q"];
 }

u.loadstack:{[stackname]
  .paths.stack:` sv .paths.conf,`stacks,stackname;
  stackd::d:.qi.readj .paths.stack,`stack.json;
  sv[`;`.conf.stacks,stackname]set d;
  def:`proc`port_offset`taskset`args`depends_on`port!(`;0N;"";();();0N);
  procs:([]name:key v)!key[def]#/:def,/:get v:d`processes;
  .conf.procs:update`$proc,7h$port_offset,`$depends_on,7h$port from procs;
  update port:port_offset+.conf.base_port from`.conf.procs where null port,not null port_offset;
  `.ipc.conns upsert select name,proc,port from .conf.procs;
  if[not`name in key .qi.opts;:(::)]; / TODO = this ever the case?
  if[not(n:`$.qi.opts`name)in key v;'"Unrecognized process name: ",string n];
  name::n;
  self::.conf.procs[n],key[def]_v n;
  proc::self`proc;
  u.load1conf .qi.path .paths.conf,`proc,` sv proc,`csv;
  u.load1conf .qi.path .paths.stack,`names,n,`name.csv;
 }

pc:{if[count d:exec name from .ipc.conns where name in .conf.self.depends_on,null handle;.log.fatal"Lost connection to ",","sv string d]}

.event.addHandler[`.z.pc;`.conf.pc];
u.loadconf`;
u.loadstack .conf.stackname;
\e 1
bar1s:flip .schema.c.Massive1s!"psffffj"$\:()

\d .u
path:.conf.stack.vars.data
init:{w::t!(count t::tables`.)#()}
del:{w[x]_:w[x;;0]?y};.z.pc:{del[;x]each t};
sel:{$[`~y;x;select from x where sym in y]}
pub:{[t;x]{[t;x;w]if[count x:sel[x]w 1;(neg first w)(`upd;t;x)]}[t;x]each w t}
add:{$[(count w x)>i:w[x;;0]?.z.w;.[`.u.w;(x;i;1);union;y];w[x],:enlist(.z.w;y)];(x;$[99=type v:value x;sel[v]y;@[0#v;`sym;`g#]])}
sub:{if[x~`;:sub[;y]each t];if[not x in t;'x];del[x].z.w;add[x;y]}
end:{(neg union/[w[;;0]])@\:(`.u.end;x)}

ld:{if[not type key L::`$(-10_string L),string x;.[L;();:;()]];i::j::-11!(-2;L);if[0<=type i;-2 (string L)," is a corrupt log. Truncate to length ",(string last i)," and restart";exit 1];hopen L};
tick:{init[];if[not min(`time`sym~2#key flip value@)each t;'`timesym];@[;`sym;`g#]each t;d::.z.D;;L::`$":",path,"/logs/tp",10#".";l::ld d};

endofday:{end d;d+:1;if[l;hclose l;l::0(`.u.ld;d)]};
ts:{if[d<x;if[d<x-1;system"t 0";'"more than one day?"];endofday[]]};
if[system"t";
 .z.ts:{pub'[t;value each t];@[`.;t;@[;`sym;`g#]0#];i::j;ts .z.D};
 upd:{[t;x]
 if[not -12=type first first x;if[d<"d"$a:.z.P;.z.ts[]];a:"p"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]];
 t insert x;if[l;l enlist (`upd;t;x);j+:1];}];

if[not system"t";system"t 1000";
 .z.ts:{ts .z.D};
 upd:{[t;x]ts"d"$a:.z.P;
 if[not -12=type first first x;a:"p"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]];
 f:key flip value t;pub[t;$[0>type first x;enlist f!x;flip f!x]];if[l;l enlist (`upd;t;x);i+:1];}];

heartbeat:{
    pname:first`$.Q.opt[.z.x]`name;
    info:(`pid`used`heap)!(.z.i;.Q.w[]`used;.Q.w[]`heap);
    neg[first exec handle from .ipc.conns where name=pname](`.c2.heartbeat;pname;info)
 }
\d .
.u.tick[]
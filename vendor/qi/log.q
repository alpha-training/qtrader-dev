\d .log

/ config settings
cfg.LEVELS:`error`warn`info`debug`trace
cfg.LEVEL:cfg.LEVELS?`info
cfg.FORMAT:`logfmt
cfg.FIELDS:()!()
now:{.z.p}
stdout:-1

/ TODO - handle, user (who)
/ isText:{type[x]in -10 10h}
seval:{[f] $[(t:type r:f@(::))in -10 10h;r;t<0;string r;-3!r]}
render.plain:{" "sv get @[x;`msg;.j.s]}
render.logfmt:{" "sv "="sv'flip(string key x;get @[x;`msg;.j.s])}
render.json:.j.j

format:{[fmt] if[not fmt in key render;bad_format];cfg.FORMAT:fmt}
level:{[lvl] cfg.LEVEL:cfg.LEVELS?lvl}
fields:{[d] cfg[`FIELDS]:d}

init:{[d]
  if[`level in key d;level d`level];
  if[`format in key d;format d`format];
  }

printx:{[context;lvl;x]
 if[cfg.LEVEL<cfg.LEVELS?lvl;:()];d:();
 if[not type msg:x;
  if[(0<count d)&99<>type d:last msg;'"second arg must be a fields dict when passing a non-string arg"];
  msg:first x];
 fields:`ts`lvl`msg!(string now`;string lvl;msg);
 fields,:cfg.FIELDS,context,$[count d;d;()];
 fields:@[fields;where 100<=type each fields;seval];
 stdout render[cfg.FORMAT]fields;
 }

print:printx()!()
{.log[x]:print x}each cfg.LEVELS;

with:{[context] (1#.q),k!{printx[x;y]}[context]each k:cfg.LEVELS}

\d .

/

.log.init`level`format!(`trace;`json)
.log.info"testing"
.log.fields`pid`test`handle!(string .z.i;"some arg";{.z.w})
.log.warn"testing again"
.log.warn("next test";`arg5`ts!("yes";string .z.d))
.log.format`json
.log.error("next test";`arg5`ts!("yes";string .z.d))
.log.format`plain
.log.error("next test";`arg5`ts!("yes";string .z.d))
myLog:.log.with`test`now!("hey";"10 20")
myLog.info "yoyo"

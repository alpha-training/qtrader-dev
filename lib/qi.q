/ qi - q/kdb+ helper functions

\d .qi

DEFAULT_OWNER:"alpha-training"
RAW:"https://raw.githubusercontent.com/"
API:"https://api.github.com/repos/"
TOKEN:getenv`GITHUB_TOKEN
PKGS:PROCS:0#`
getAPI:{[isTag;repo;ref] API,repo,"/git/refs/",$[isTag;"tags";"heads"],"/",ref}

tostr:{$[0=count x;"";0=t:type x;.z.s each x;t in -10 10h;x;string x]}
tosym:{$[0=count x;`$();0=t:type x;.z.s each x;t in -11 11h;x;`$tostr x]}
path:{$[0>type x;hsym tosym x;` sv @[raze tosym x;0;hsym]]}     /  returns `:path/to/file
spath:1_string path@    / returns "path/to/file"
exists:{not()~key path x}
isfile:{p~key p:path x}
files:{(raze/){$[p~k:key p:path x;p;.z.s each p,'k]}x}
fenv:{[v;default;f] sv[`;`env,v]set $[count r:getenv v;f r;default];}
envpath:{path @[x;0;env]}
dotq:{$[x like"*.*";x;`$tostr[x],".q"]}
opts:first each .Q.opt .z.x

log.print:{[typ;x] $[type x;-1;-1" "sv]"qi ",typ," ",string[.z.p]," ",x}
log.info:log.print"info";log.warn:log.print"warn";log.error:log.print"error"

/ web & json
curl:system("curl -fsSL ",$[count TOKEN;"-H \"Authorization: Bearer ",TOKEN,"\" ";""]),
jcurl:.j.k raze curl@
fetch:{[url;p] log.info"fetch ",url;path[p]0:curl url}
readj:.j.k raze read0 path@

/ file system
loadf:{[p] system"l ",spath dotq p;}
loadmodule:{[p;name]
  system"l ",spath p,dotq name;
  if[count initf:@[get;` sv`,name,`init;()];initf p];
  }

fenv[`QI_INDEX_URL;RAW,DEFAULT_OWNER,"/qi/main/index.json";::]
fenv[`QI_HOME;hsym`$getenv[`HOME],"/.qi";path]
fenv[`QI_VENDOR;`:vendor/qi;path]
fenv[`QI_LOCK;`:qi.lock;path]
fenv[`QI_CONFIG;`:qi.json;path]
fenv[`QI_OFFLINE;0b;"1"=first@]

getindex:{[refresh] $[refresh|not exists p:path(env.QI_HOME;`cache;`index.json);fetch[env.QI_INDEX_URL;p];p]}

try:{[func;args;catch] $[`ERR~first r:.[func;args;{(`ERR;x)}];(0b;catch;r 1);(1b;r;"")]}
try1:{try[x;enlist y;z]}

infer:{[m;x]
  if[0=count x;:x];
  if[(t:type x)in 0 98 99h;:.z.s[m]each x];
  if[t<>10;:x];
  if[" "in x;:$[a~inter[a:-1_x].Q.n," .:D";get x;.z.s[m]each x]];   / restricted get for infosec
  if[" "<>i:(x like/:m)?1b;:i$$[i="M";-1_x;x]];
  if[x~x inter .Q.n,".";:("JF""."in x)$x];
  $[":"=x 0;`$x;0=s:sum x="`";x;"`"<>x 0;x;`$1_$[s=1;x;"`"vs x]]
  }{"PTVUDMB"!(d,"D*";v,".",x,"*";v:u,":",a;u:a,":",a;d:m,y,a;(m:a,a,y,a:x,x),"m";"[0-1]")}["[0-9]";"[.-/]"]

reg:{[name;ismodule] $[ismodule;`.qi.PKGS;`.qi.PROCS]?name;}

pmanage:{[ismodule;x]
  if[(name:first` vs sx:tosym x)in PKGS;:(::)];
  if[name in key`;:(::)];
  log.info $[ismodule;"Loading ";"Checking for "],string name;
  if[exists pv:envpath`QI_VENDOR,name;
    reg[name;ismodule];
    :loadmodule[pv;name]];
  if[exists pl:env.QI_LOCK;
    dbg2];
  if[exists pc:env.QI_CONFIG;
    dbg3];
  m:readj[getindex 0b][`procs`modules ismodule]name;
  repo:$["/"in m`repo;m`repo;DEFAULT_OWNER,"/",m`repo];

  isTag:m[`ref]like"v[0-9]*";refresh:1b;
  obj:jcurl[getAPI[isTag;repo;m`ref]]`object;
  sha:obj`sha;
  if[isTag;
    if["tag"~obj`type;
      sha:jcurl[API,repo,"/git/tags/",obj`sha][`object]`sha];
      dir:envpath(`QI_HOME;`procs`pkgs ismodule;name;m`ref)];
  if[not isTag;
    dir:envpath(`QI_HOME;`procs`pkgs ismodule;name;`refs;m`ref);
    if[exists cf:path dir,`current;
      refresh:not sha~raze read0 cf]];
  dir2:path dir,$[isTag;();(`store;sha)];
  mp:path dir2,f;   / TODO - f not defined here
  if[refresh;
    tree_sha:jcurl[API,repo,"/git/commits/",sha][`tree]`sha;
    treeInfo:`typ xcol`type`path#/:jcurl[API,repo,"/git/trees/",tree_sha,"?recursive=1"]`tree;
    {[api;dir2;sha;fp]
      url:api,"/",sha,"/",fp;
      if[not exists p:path(dir2;fp);fetch[url;(dir2;fp)]]}[RAW,repo;dir2;sha]each exec path from treeInfo where typ like"blob";
    if[not isTag;
      path[dir,`lastFetch]0:enlist string .z.p;
      cf 0:enlist sha]];

  loadcfg[name;first` vs mp];
  reg[name;ismodule];
  if[ismodule;loadf mp];
  }

addproc:pmanage 0b
include:.qi.use:pmanage 1b

\

.qi.system:{log.info"system ",x;system x}

resolvej1:{
    env:`;
    if[not count r:$[not(::)~r:vars sa:`$a:2_-1_y;r;env:a like"env:*";getenv env:`$4_a;a like".z.*";get a;()];
      if[not null env;'"Unresolved env variable ",string env];
      x];
    ssr[x;y;tostr r]}

/resolvej1:{$[count r:$[not(::)~r:vars sa:`$a:2_-1_y;r;a like"env:*";getenv`$4_a;a like".z.*";get a;()];ssr[x;y;tostr r];x]}

resolvej:{$[count v:x ss"${";resolvej1/[x;{y[0]_(1+y 1)#x}[x]each v,'x ss"}"];x]}
expandj:{$[(t:type x)in 0 99h;.z.s each x;t=10;resolvej x;x]}each
parsej:{[p] .conf,:1#e:1#.q;vars::e;if[`vars in key a:readj p;vars,:v:a`vars;{vars[y]:r:resolvej x y;.conf[y]:r}[v]each key v];expandj a}

if[`loadf in key opts:first each .Q.opt .z.x;
  -1"hit loadf section in qi";
  loadf opts`loadf];


loadstack:{[f]
  procs:(r:.qi.parsej f)`processes;
  if[count invalid:except[p:`$distinct get procs[;`proc]]vp:key .qi.readj[.qi.getindex 0b]`procs;
    :log.error"Invalid process type: ",sv[",";string invalid],". Must be one of: ",","sv string vp];
  .qi.addproc each p;
  .conf,:1#.q;
  d:`version`stack`host`base_port!"*SSj";
  .conf,:cfg:{(k#x)$(k:key[x]inter key y)#y}[d;r];
  def:`proc`cmd`port_offset`taskset`args`depends_on`port!(`;"";0N;"";();();0N);
  procs:([]name:key v)!key[def]#/:def,/:get v:r`processes;
  .conf.procs:update`$proc,7h$port_offset,`$depends_on,7h$port from procs;
  update port:port_offset+cfg`base_port from`.conf.procs where null port,not null port_offset;
  update port:cfg`base_port from`.conf.procs where proc=`c2;
 }


loadcfg:{[module;dir]
  f:$[(def:`default.csv)in f:key p:` sv dir,`config;distinct def,f;f];
  if[not count f@:where f like"*csv";:()];
  get".",tostr[module],".cfg,:1#.q";  / TODO - could this be nicer?
  {[ns;p;f]
    r:exec name!upper[typ]$default from("SC*";enlist",")0:` sv p,f;
    @[ns;`cfg;,;r]}[` sv `,module;p]each f;
  if[exists pp:` sv p,`pp.q;loadf pp];  / if post-process file (pp.q) exists, load it
 }

tcfg:1#.q
guess:{$[(t:type x)in 0 98 99h;.z.s each x;10<>abs t;x;-10=t;$["*J"x in .Q.n]x;","in x;.z.s each","vs x;x~x inter .Q.n,".";$["JF""."in x]x;"S"$x]}
d:.j.k raze read0 `:test.json
.qi.resolve[;getenv]each d`env
/.qi.resolve[;{tcfg[x]:tcfg x}]each d`defaults

\

{{[d;k] tcfg[k]:.qi.resolve[d k;get]}[d]each [d]each key d`defaults;

/
.qi.resolve[;{tcfg[x]set get x}]each d`defaults

\
r:{$[(t:type x)in 0 99h;.z.s each x;t=10;.qi.expand x;x]}each 

\

/p.home:{envpath[`QI_HOME;getenv`HOME;dotq x]}
/p.index:{envpath[`QI_INDEX;x;y]}[;`index.json]

INDEX:
/ envpath:{[env;default;x]path($[count a:getenv env;a;default];$[any x~/:(::;`);();x])}
\

INCLUDED:0#`

fetch:{[dir;p;x] system"mkdir -p ",spath first ` vs p;system"wget -O ",spath[p]," ",REPO,dir,"/",tostr $[dir~"lib";dotq x;x]}
fetchcfg:fetch"config"
fetchlib:fetch"lib"
include:{a:first` vs x;if[not a in REPO_LIBS;'"unrecognized library"];if[not a in INCLUDED;if[not exists p:qilib a;fetchlib[p;a]];system"l ",spath p;INCLUDED,:a]}
includecfg:{if[not exists p:qiconfig x;fetchcfg[p;x]]}
now:{.z.p};today:{.z.d}

\d .q
{{$[b;last` vs x;x]set get$[b:"."=first s:.qi.tostr x;x;` sv`.qi,x]}each $[.qi.exists x;`$read0 x;()]}.qi.qiconfig`promote.txt;
\d .
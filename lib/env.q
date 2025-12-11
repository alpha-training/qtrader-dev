\d .env

f.loadEnv:{
 a:("S**";enlist",")0:`:conf/env.csv;
 a:update {$[0=c:count x;::;1=c;upper[first x]$;get x]}each f from a;
 a:update f@'default from a;
 exec .qi.env'[v;default;f]from a;
 }

f.loadEnv[];
QT_CONF:` sv QT_HOME,`conf
QT_STACKS:` sv QT_CONF,`stacks
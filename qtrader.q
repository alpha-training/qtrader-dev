/ qtrader entry file
/ q qtrader.q -name [process name]

\l lib/common.q

.qi.loadf` sv`:proc,.conf.proc;
if[not system"t";system"t ",.qi.tostr .conf.qtimer]
if[not system"p";system"p ",.qi.tostr .conf.self.port];
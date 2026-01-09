/ translate qsharpe files into q
/ 1) create a json syntax tree
/ 2) write q

\d .qs

/ entry function
l:{[p]
  s:read0 .qi.path p;
  dbg;
 }
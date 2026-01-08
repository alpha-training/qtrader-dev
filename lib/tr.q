/ Trading utilities

\d .tr

genid:{[n;x] if[not count x;:0#0]; n set last r:get[n]+$[1=c:count x;1;1+x];r}
tonote:{" "sv string[x],'"=",'string y}
fromnote:(!)."S= "0:
allocate:{$[1>=count y;y;x=sa:sum a:7h$x*y%t:sum y;a;@[a;last where ay=min ay:abs y;-;x-sa]]}
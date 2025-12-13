/ Type conversion

\d .ty

init:{[dir]TYP::(!).("C*";",")0:` sv dir,`infer.csv}

infer:{
  if[0=count x;:x];
  if[(t:type x)in 0 98 99h;:.z.s each x];
  if[t<>10;:x];
  if[" "in x;:.z.s each" "vs x];
  if[" "<>i:(x like/:TYP)?1b;:i$$[i="M";-1_x;x]];
  if[x~x inter .Q.n,".";:("JF""."in x)$x];
  $[":"=x 0;`$x;0=s:sum x="`";x;"`"<>x 0;x;`$1_$[s=1;x;"`"vs x]]
  }
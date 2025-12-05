\d .schema

c:t:1#.q

load1Schema:{[p]
  tab:first` vs last` vs p;
  a:("SC";",")0:p;
  t[tab]:flip a[0]!a[1]$\:();
  c[tab]:a 0;
  }

load1Schema each .qi.files .conf.paths.conf,`schemas;
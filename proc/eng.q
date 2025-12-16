/ Strat engine (produces intent)
/ In testing mode

sendintent:{
  a:([]time:2#.tm.now`;sym:`AAPL`AAPL;strat:`strat1`strat2;tgtpos:100 200;urgency:.5 .8;info:("";""));
  .ipc.async[`net](`intent;a);
 }
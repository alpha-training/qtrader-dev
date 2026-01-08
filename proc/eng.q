/ Strat engine (produces intent)
/ In testing mode

sendintent:{
  n:1+rand 5;
  a:([]time:n#.tm.now`;sym:neg[n]?`AAPL`JPM`TSLA`IBM`GE;strat:` sv'.conf.name,'neg[n]?`strat1`strat2`strat3`strat4`strat5;tgtpos:100*1+n?10;urgency:.1*1+n?10;info:string n#`);
  .ipc.async[`om](`intent;a);
 }
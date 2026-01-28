
/ load in data first
mrp:{
    / extract final closing price for each day
  daily:select last close by date,sym from bar1m where time=21:00:00,sym in`GLD`GDX;
  prices:exec gld:close,gdx:close_gdx by date from (select date,close from daily where sym=`GLD) lj`date xkey(select date, close_gdx:close from daily where sym=`GDX); /is this needed??
  train:252#prices; /training data to get hedge ratio
  t_train:flip(enlist[`date]!enlist key train),flip value train; / turn into table from dictionary - probably a better way to do this
  t_prices:flip(enlist[`date]!enlist key prices),flip value prices;
  /h=Beta=Cov(gdx,gld)/Var(gdx)
  h:first exec(avg[gld*gdx]-avg[gld]*avg[gdx])%var gdx from t_train; 
  / Calculate the spread:Spread=GLD-(h*GDX)
  t_train:update spread:gld-h*gdx from t_train;
  sMean:first exec avg spread from t_train;
  sStd:first exec dev spread from t_train;
  / Apply parameters to the full price table
  t_prices:update spread:gld-h*gdx from t_prices;
  t_prices:update z:(spread-sMean)%sStd from t_prices;
  / Entry Signals (Z-score thresholds of +/- 2.0)
  t_prices:update entry_long:z<=-2,entry_short:z>=2 from t_prices;
  // Create the 'pos' (Position) column
  t_prices:update pos:calc_state\[0;z] from t_prices;  / CHECK LOGIC- MAY not work
 
}

calc_state:{[s;z]
  $[s=0; $[z<=-2; 1; z>=2; -1; 0];
    s=1; $[z>=-1; 0; 1];
    s=-1;$[z<=1; 0; -1]; 
    0]};
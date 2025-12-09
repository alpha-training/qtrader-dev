\l p.q / Load EmbedPy

/ Setup Python Path
sys:.p.import`sys;
sys[`:path.append]"src";

yhMod:.p.import`qtrader.providers.yahoo.historical.rest; /Import Custom Module

/ --- The Python Helper ---
/ Returns List of Rows (Strings).
p)def get_raw_rows(df):
    # Flatten header
    df.columns = ['time','sym','open','high','low','close','volume']
    # Convert EVERYTHING to strings
    return df.astype(str).values.tolist()

getHistory:{[ticker;days]
  client:yhMod[`:YahooHistorical][];
  period:string[days],"d";
  pyDf:client[`:get_bars][ticker;`period pykw period;`interval pykw"1h"]; /Fetch Data (Python)
  rawList:.p.eval["get_raw_rows"]pyDf; / Convert to Raw Strings (Python)
  data:rawList`; / Move to q
  c:flip data;
  :tab:([]
    time:"Z"$c[0];
    sym:"S"$/:c[1];
    open:"F"$c[2];
    high:"F"$c[3];
    low:"F"$c[4];
    close:"F"$c[5];
    volume:"J"$c[6])
 };

/
run this 
q src/qtrader/providers/yahoo/yahoo.q
getHistory[`NVDA;5]
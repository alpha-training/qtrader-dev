\l p.q / Load EmbedPy

/ Setup Python Path
sys:.p.import`sys;
sys[`:path.append]"src";

msRest:.p.import`qtrader.providers.massiveapi.historical.rest;
msReal:.p.import`qtrader.providers.massiveapi.realtime;
msNorm:.p.import`qtrader.providers.massiveapi.normalize;

p)def get_raw_rows(df):
    df.columns = ['datetime','ticker','open','high','low','close','volume']
    return df.astype(str).values.tolist()

getHistory:{[ticker;dateRange]
    t:{[ticker;dR] tkr:string ticker;
    client:msRest[`:MassiveREST][`api_key pykw "rSQLz8C1muscWBydEkoAWpW4RH9CW_wq"];
    raw:client[`:fetch_aggs][`ticker pykw tkr;`from_ pykw first dR;`to pykw last dR];
    pyDf:msNorm[`:normalize_aggs][raw;`ticker pykw tkr];
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
    volume:"J"$c[6])}[;ssr[;".";"-"] each string dateRange] each ticker;
    if[1<>count ticker;t:raze t];
    t
    }
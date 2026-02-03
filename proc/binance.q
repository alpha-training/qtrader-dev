/ Error trap and connect to tickerplant - - need ipc logic
\e 1
/ 2. The Connection Logic
/ We define the host and the resource separately to avoid 'No route' parsing errors
host:":wss://stream.binance.com:443";
tickers:`btcusdt`ethusdt`solusdt;
bars:"@kline_1m"
tickerspath:"/" sv string[tickers],\:bars
path:"/stream?streams=",tickerspath;

/ Construct the header with the specific resource path
header:"GET ",path," HTTP/1.1\r\nHost: stream.binance.com\r\nConnection: Upgrade\r\nUpgrade: websocket\r\n\r\n";

/ The Binance Data Handler (Updated for the dictionary you just showed me)
.z.ws:{[msg]
    raw:.j.k msg;
    / UNWRAP: If 'data' is a key, the real message is inside it
    data:$[`data in key raw;raw`data;raw];
    if[data[`e]~"kline";
        k:data`k;
        neg[.ipc.conn`tp0](`.u.upd;`$data`e;(
            12h$1970.01.01D+1000000*7h$k`t;
            `$k`s;
            "F"$k`o;
            "F"$k`h;
            "F"$k`l;
            "F"$k`c;
            ("F"$k`q)%"F"$k`v;
            "F"$k`v
        ));
        / Updated print statement to show WHICH symbol closed
        if[k`x;-1 "qi.binance: [CLOSED] ",k[`s]," at ",k`c];
    ];
 };

/ 4. Open the Handle
/ We cast the host string directly to ensure kdb+ treats it as a destination
w:hsym[`$host]header;

/ Check if connected
$[first w>0;-1 "AlphaKDB: Connection Success. Handle: ",first string w 0;-1 "AlphaKDB: Connection Failed"];

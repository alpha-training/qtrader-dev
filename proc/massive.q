/ conenct to tp and set error trap
/h:hopen 5051
\e 1
/--- 1. Define the AlphaKDB Schema ---
/ We'll track the basics: Time, Symbol, Close Price, and Volume
trade:flip`time`sym`open`high`low`close`vwap`size!"psfffffj"$\:();

/--- 2. Connection Setup ---
url:":wss://delayed.massive.com:443";
header:"GET /stocks HTTP/1.1\r\nHost: delayed.massive.com\r\n\r\n";
API_KEY:"rSQLz8C1muscWBydEkoAWpW4RH9CW_wq";
TICKERS:"AM.*";

/--- 3. The Parser Logic (Reacting to wscat output) ---
.z.ws:{[msg]
    packets:.j.k msg;
    / Massive sends a list of dicts, so we use 'each'
    {
        / If it's a data packet (AM)
        if[x[`ev]~"AM";
            neg[.ipc.conn`tp0](`.u.upd;`$x`ev;(
            12h$1970.01.01D+1000000*7h$x`s; / Start Time (s) 
            `$x`sym;                        / Symbol
            9h$x`o;                           / Open
            9h$x`h;                           / High
            9h$x`l;                           / Low
            9h$x`c;                           / Close
            9h$x`vw;                          / VWAP (vw)
            7h$x`v                            / Volume (v)
        ));
        -1 "qi.ingest: Captured ",x[`sym], " at ",string[x`c];
        ];

        / If it's a status packet, handle the handshake/auth
        if[x[`ev]~"status";
            if[x[`status]~"connected";neg[.z.w] .j.j`action`params!("auth";API_KEY)];
            if[x[`status]~"auth_success";neg[.z.w] .j.j`action`params!("subscribe";TICKERS)];
            -1 "qi.status: ",x`message;
        ];
    }each packets;
 };

/--- 4. Launch the Pipe ---
w:hsym[`$url]header;
-1 "AlphaKDB v0.1: Connection sequence initiated...";


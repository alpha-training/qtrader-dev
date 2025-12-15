# Configuration settings in qtrader 

**qtrader** settings are stored in .conf files, that proceed from the general to specific. Let's imagine we have a process `tp0` running in a stack `dev1`,  the following files will be loaded (where they exist). 

| File | Scope | Example | Background |
|---------|---------|-----------|------------|
| `conf/global.conf` | Global | qtimer=100 | Run q timer 10x per second
| `conf/local.conf` | Local	| API_KEY=G%*HSKK& | Not checked in, similar to .env
| `conf/proc/tp.conf` | Process type | qtimer=50 | Faster q timer for tickerplants
| `conf/dev1/stack.conf`| Stack (collection) | base_port=1000 | Different stacks  use different base ports
| `conf/dev1/names/tp0/name.conf` | Process name (instance) | qtimer=25 | Even faster timer for time sensitive tickerplant

If the same setting is found in two or more files, the most recently loaded takes precedence i.e. the most specific. 



## Loading settings

All settings are loaded into the `.conf` namespace, and the types are inferred when loaded. Two features deserve special mention:

1. Values beginning with : will be cast to a symbol
2. `$name` will be resolved as `.conf.name`

| In file | q variable |q value |note 
|---------|---------|-----------|------------|
| ibkr_key=gh5678%^&* | .conf.ibkr_key | "gh5678%^&*" | left as string
| qtimer=1000 | .conf.qtimer | 100 | type long
| weights=0.5 .75 | .conf.weights | 0.5 0.75 | type float
| max_hold=120h | .conf.max_hold | 120h | type short
| universe=```JPM`GE`IBM`` | .conf.universe | ``JPM`GE`IBM`` | symbols
| data=/disk01/data|.conf.data| "/disk01/data" | left as string|
| data=:/disk01/data|.conf.data| `:/disk01/data | cast to symbol if : is first char|
|tplogs=$data/tp|.conf.tplogs|`:/disk01/data/tplogs |  Variables are expanded


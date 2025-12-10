# qtrader Order Lifecycle Walkthrough
A complete, step-by-step example of how **two strategies** express intent, how netting aggregates their targets, how the OMS produces orders, how fills arrive, and how positions update.

## **Intent**
```
time,p
sym,s
strat,s
tgtpos,j
urgency,f
info,*
```

## **Order**
```
time,p
sym,s
orderid,j
side,h
price,f
size,j
status,s
pending,j
filled,j
algo,s
urgency,f
tsnew,p
tsupdate,p
note,*
```

---

# 1. System Setup

We assume:

- Strategy engine: **eng.q**
- Netting engine: **net.q**
- Order manager: **om.q**
- Broker gateway: **ibkr** (TWS/Gateway/FIX)
- Symbol: `AAPL`
- Current actual position (`net.Pos`): **0**

Two strategies:

- **strat1 (mean reversion)**
- **strat2 (momentum)**

Both produce intent independently.

---

# 2. Strategy Intent Arrives (eng → net)

## **2.1 strat1 expresses intent**
Time: `09:30:01.000`

```
Intent:
time:     09:30:01.000
sym:      AAPL
strat:    strat1
tgtpos:   +100
urgency:  0.3
info:     ""
```

Meaning:
- strat1 wants to be **long 100**, not urgently.

---

## **2.2 strat2 expresses intent**
Time: `09:30:01.010` (10 ms later)

```
Intent:
time:     09:30:01.010
sym:      AAPL
strat:    strat2
tgtpos:   +200
urgency: 0.8
info:     ""
```

Meaning:
- strat2 wants **long 200**, with higher urgency.

---

# 3. Netting Aggregates Intent (net.q)

Net holds:

```
Intent:
strat1: +100
strat2: +200
```

Current position (`net.Pos`): **0**

### **Aggregate target (Agg):**
```
aggtgt = 100 + 200 = +300
```

### **Required delta:**
```
req = aggtgt - current_pos
    = +300 - 0
    = +300
```

So net sends:

```
Req: (sym:`AAPL; size:300)
```

Urgencies can also be aggregated.

---

# 4. Order Manager Creates Orders (net → om)

`om.q` receives:

```
Req for AAPL: buy 300
```

Execution logic decides:

- one order? multiple slices?
- limit or market?
- algo (based on urgency)?

Assume:
- limit price = market bid + 0.01 = 182.50
- algo = `twap`
- urgency = 0.6 (weighted from hints)

`om` creates an **Order**:

```
time:       09:30:01.020
sym:        AAPL
orderid:    1000001
side:       1h          / buy
price:      182.50
size:       300
status:     `NEW
pending:    300
filled:     0
algo:       `twap
urgency:    0.63333			/ 100 200 wavg 0.3 0.8
tsnew:      09:30:01.020
tsupdate:   09:30:01.020
note:       "TWAP child #1"
```

`om` sends the order to IBKR.

---

# 5. Broker Accepts the Order (om ← ibkr)

IBKR responds:

```
orderid: 1000001
status: `NEW
```

`tsupdate` is updated.

---

# 6. Partial Fills Arrive (ibkr → om)

At `09:30:01.500`, IBKR sends a **trade**:

```
trade: +75 @ 182.50
```

OMS updates the Order:

```
filled:     75
pending:    225
status:     `PARTIAL
tsupdate:   09:30:01.500
```

OMS also updates `Position`:

```
pos += 75   → 75
```

OMS pushes this updated position back to net.q.

---

# 7. Netting Recalculates (net ← om)

New position: **75**

Intent totals still = 300.

```
req = 300 - 75 = 225
```

net.q tells om.q:

```
Still need +225 shares
```

Execution continues.

---

# 8. Second Fill Arrives

At `09:30:02.000`:

```
trade: +225 @ 182.51
```

Order becomes:

```
filled:     300
pending:    0
status:     `FILLED
```

Position becomes:

```
pos = 300
```

net receives:

```
pos: 300
aggtgt: 300
req: 0
```

System is fully aligned.

---

# 9. Summary Timeline

| Time | Actor | Event |
|------|--------|--------|
| 09:30:01.000 | strat1 | Intent: tgtpos +100 |
| 09:30:01.010 | strat2 | Intent: tgtpos +200 |
| 09:30:01.015 | net | Agg=300, Pos=0, Req=300 |
| 09:30:01.020 | om | Create Order(300 @182.50) |
| 09:30:01.500 | ibkr | Fill +75 |
| 09:30:01.501 | om | Update Order, Pos=75 |
| 09:30:01.502 | net | Req=225 |
| 09:30:02.000 | ibkr | Fill +225 |
| 09:30:02.001 | om | Order FILLED, Pos=300 |
| 09:30:02.002 | net | Req=0 |

---

# 10. Architectural Separation

| Component | Responsibility |
|-----------|----------------|
| **eng.q** | strategy intent (desired position) |
| **net.q** | aggregate positions & compute required deltas |
| **om.q** | execution logic, orders, fills |
| **ibkr** | external marketplace |
| **net.q** | re-evaluate after fills |

---

If you'd like, I can also generate:
- a version with cancel/replace logic  
- version with opposing strat intents (netting scenario)  
- diagram version (Mermaid or ASCII)
# What happened — PERF-003 in plain language

**Folder:** [`investigations/qdrant-retrieval-scaling/`](./) · Issue [#7](https://github.com/UdonsiKalu/cxr-portfolio/issues/7)

---

## What we asked

When many searches hit Qdrant at once, does retrieval get slower or break?

---

## What we found

**A little slower, not broken.**

- At **8 → 64** concurrent searches: **0 failures**
- Search time stays around **~20–40 ms** (tens of ms)
- Throughput climbs, then **levels off ~280 requests/sec**
- So there **is** impact (don’t say “no impact”), but **no crash / error cliff**

| Concurrency | p50 | p95 | RPS | Failures |
|------------:|----:|----:|----:|---------:|
| 8 | 23 ms | 359 ms* | 119 | 0 |
| 16 | 37 ms | 66 ms | 291 | 0 |
| 32 | 32 ms | 48 ms | 280 | 0 |
| 64 | 29 ms | 56 ms | 282 | 0 |

\*c=8 p95 includes **warmup**; steady tiers ~**50–66 ms** p95.

Numbers match the instrumented re-run in Jaeger and [`results/qdrant-direct-pressure-summary.txt`](./results/qdrant-direct-pressure-summary.txt).

---

## What this is *not*

The long Analyze times (**~15–30 seconds**) are mostly **not** Qdrant. In Jaeger, Analyze’s **`retrieval`** is still ~**76–87 ms**. The heavy time is elsewhere (imports, corrector, SQL, queue).

---

## How we proved it

1. **CSV timings** from a direct Qdrant pressure script (`run-qdrant-direct-pressure.py`)
2. **Jaeger** under service **`cxr-qdrant-pressure`** — tier Tags for concurrency **8 / 16 / 32 / 64**

---

## Pictorial evidence

### 1. Full pressure run (one Jaeger trace)

Service **`cxr-qdrant-pressure`**, op **`qdrant.pressure.run`** — four bumps = tiers 8 / 16 / 32 / 64.

![Pressure run waterfall](screenshots/jaeger-pressure-run-waterfall.png)

Root tags: `pressure.tiers=8,16,32,64`, `requests_per_tier=64`, collection `claims__cms_policies`.

![Pressure run tags](screenshots/jaeger-pressure-run-tags.png)

### 2. Compare tiers (Tags on `qdrant.pressure.tier`)

**c=8** — warmup p95, lower RPS:

![Tier concurrency 8](screenshots/jaeger-tier-concurrency-8.png)

**c=16** — RPS jumps ~290:

![Tier concurrency 16](screenshots/jaeger-tier-concurrency-16.png)

**c=32** — plateau:

![Tier concurrency 32](screenshots/jaeger-tier-concurrency-32.png)

**c=64** — still ~282 RPS, p50 ~29 ms, 0 fails:

![Tier concurrency 64](screenshots/jaeger-tier-concurrency-64.png)

### 3. Analyzer path (not the hard ramp)

Analyze still calls Qdrant: Jaeger **`retrieval` ~76 ms**, **`retrieved_chunk_count=5`** inside a ~15 s Analyze — Qdrant is active but not the wall-clock bottleneck.

![Analyzer retrieval 76ms](screenshots/jaeger-analyzer-retrieval-76ms.png)

### 4. Light Analyze concurrency table

![Concurrency tier table](screenshots/results-table-retrieval-scaling.png)

---

## What we did

1. Started Qdrant with real policy data (~**46k** points).
2. Warm analyzer connected to Qdrant.
3. **Light pressure:** Analyze at **1, 3, 5, 8** concurrent.
4. **Hard pressure:** direct concurrent searches **8 → 64** on `claims__cms_policies` (bypass Analyze).
5. **Instrumented** the pressure client with OpenTelemetry → Jaeger service **`cxr-qdrant-pressure`**.
6. Compared tier Tags in Jaeger (`pressure.concurrency`, `pressure.ms_p50`, `pressure.rps`).

---

## How this differs from “Qdrant outage”

| Study | Question |
|-------|----------|
| **DEP-001** | Qdrant **off** — soft fallback for Analyze |
| **PERF-003** | Qdrant **on** and busier — **measure** p50/p95/RPS vs concurrency |

---

## Bottom line

- Ramp-up **is measured** (CSV + Jaeger), not guessed.
- Impact **exists** (latency + RPS plateau); **no** search failures at 64 concurrent in this lab.
- Do **not** look for the hard ramp under analyzer **`retrieval`** — use service **`cxr-qdrant-pressure`**.
- Scripts: [`run-retrieval-scaling-check.sh`](./run-retrieval-scaling-check.sh) · [`run-qdrant-direct-pressure.py`](./run-qdrant-direct-pressure.py)  
- Technical write-up: [`README.md`](./README.md)

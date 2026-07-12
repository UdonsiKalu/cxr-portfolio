# PERF-003 — Qdrant retrieval scaling

| | |
|---|---|
| **Status** | Complete (2026-07-12) |
| **ID** | PERF-003 (issue [#7](https://github.com/UdonsiKalu/cxr-portfolio/issues/7)) — **not** the K8 context-builder “PERF-003” in older CHANGELOG entries |
| **Question** | How does retrieval latency / throughput change as we ramp concurrent Qdrant search? |
| **Tools** | Direct timed Qdrant search + OTel, Analyze concurrency sweep, Jaeger |
| **Environment** | UI `:8251`, warm analyzer `:8766`, Qdrant + `cxrlabs` storage (~**46k** points) |
| **Related** | [Qdrant outage (DEP-001)](../archive/old-investigations/qdrant-outage/) · [REL-004 SQL](../database-unavailable/) |

**Plain English + screenshots:** [RESULTS.md](./RESULTS.md)

---

## Short story

**The ramp is measured** (CSV + Jaeger **`cxr-qdrant-pressure`**). Concurrent Qdrant search **does** have impact (latency up, RPS plateau ~280), but stays in the **tens of ms** with **0** failures — **not** “no impact,” and **not** the reason Analyze is ~15–30s.

---

## Pictorial evidence

![Pressure run waterfall](screenshots/jaeger-pressure-run-waterfall.png)

**Tier Tags (compare concurrency 8 → 64):**

![Tier c=8](screenshots/jaeger-tier-concurrency-8.png)

![Tier c=16](screenshots/jaeger-tier-concurrency-16.png)

![Tier c=32](screenshots/jaeger-tier-concurrency-32.png)

![Tier c=64](screenshots/jaeger-tier-concurrency-64.png)

More: [screenshots/README.md](./screenshots/README.md) · full story in [RESULTS.md](./RESULTS.md)

---

## Method

```bash
./investigations/qdrant-retrieval-scaling/run-retrieval-scaling-check.sh
python3 investigations/qdrant-retrieval-scaling/run-qdrant-direct-pressure.py
```

Direct pressure times each `points/search` → `results/qdrant-direct-pressure.csv` and exports OTLP spans (default).

**Jaeger:** Service **`cxr-qdrant-pressure`** → open **`qdrant.pressure.run`** → compare **`qdrant.pressure.tier`** Tags (`pressure.concurrency` 8/16/32/64).  
Disable tracing: `CXR_PRESSURE_TRACE=0`.

---

## Results (2026-07-12, instrumented re-run)

| Concurrency | ok/n | p50 ms | p95 ms | RPS |
|------------:|------|-------:|-------:|----:|
| 8 | 64/64 | 23.0 | 358.8* | 118.8 |
| 16 | 64/64 | 37.1 | 66.0 | 290.5 |
| 32 | 64/64 | 32.3 | 48.4 | 279.5 |
| 64 | 64/64 | 29.3 | 55.6 | 282.1 |

\*warmup. Raw: [results/qdrant-direct-pressure-summary.txt](./results/qdrant-direct-pressure-summary.txt)

---

## Findings

1. Ramp **is measured** (CSV + Jaeger), not only narrated.
2. “64 concurrent = no impact” is **incorrect**.
3. Correct: **small impact, no failure cliff**.
4. Analyzer multi-second latency is mostly **non-Qdrant**.

---

## Decision

- Document p50/p95/RPS vs concurrency from CSV and tier Tags.
- Never claim zero impact; claim **bounded impact + no errors** for this band.
- Blame Analyze path first when wall clock is seconds and `retrieval` is tens of ms.

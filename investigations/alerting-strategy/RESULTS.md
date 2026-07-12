# What happened — OBS-003 Alerting strategy (plain English)

**Folder:** [`investigations/alerting-strategy/`](./) · Issue [#19](https://github.com/UdonsiKalu/cxr-portfolio/issues/19)

---

## What we asked

What should we **alert on** for claim analysis — so the next outage or slowdown pages the right people, and we don’t cry wolf?

---

## What we found (short)

Use the labs you already ran as the rulebook:

| Situation | What the lab showed | Alert style |
|-----------|---------------------|-------------|
| **SQL down** | Analyze **HTTP 500**; claim work stops | **Page** |
| **Analyzer down / not warm** | Analyze fails or hangs | **Page** |
| **Ollama down** | Analyze can still work; **Auditor** fails | **Ticket** (not a full outage page) |
| **Qdrant down** | Analyze often still **200** with fallback; weaker policy support | **Ticket** (degraded) |
| **Qdrant busy (8→64)** | Searches stay ~**20–40 ms**; RPS plateaus; **0** fails | **Watch metrics** — don’t page for “Qdrant busy” alone |
| **Analyze takes 15–30 s** | Often **not** Qdrant (`retrieval` ~**76–87 ms**) | Don’t page on wall clock alone — check Jaeger |

---

## What we asked vs what we are *not* doing

This study is a **strategy** from evidence — not a new chaos run, and not “Prometheus is fully wired in prod.” Local SLOs stay **dev targets** ([slos-and-slis.md](../../archive/investigations-supplemental/slos-and-slis.md)).

---

## Proposed alerts (concrete)

### Page (wake someone)

**A1 — Analyze error rate**  
- **When:** share of Analyze responses that are **5xx** (or UI “Failed to analyze claim”) rises above a small threshold for a few minutes.  
- **Why:** REL-004 — SQL unreachable → hard fail; users cannot complete claims.  
- **Signal ideas:** HTTP status from UI/analyzer; count of failed POSTs.

**A2 — Analyzer health**  
- **When:** `GET :8766/health` fails or `warmed` is false for longer than a boot window.  
- **Why:** no warm analyzer ⇒ Analyze broken or multi‑minute cold path.

**A3 — SQL probe**  
- **When:** Terminal-style DB check / TCP `:1433` login probe fails.  
- **Why:** same root as A1; can fire *before* users hammer Analyze (REL-004 diag failed fast).

### Ticket (work hours / degrade)

**A4 — Auditor / Ollama**  
- **When:** Auditor status shows connect failure to Ollama (REL-002 OFF path).  
- **Why:** Compliant Analyze may still succeed; judgment path is soft.

**A5 — Qdrant degraded**  
- **When:** Qdrant unreachable **or** Analyze returns **`policy_support=0`** while we expect policy RAG (DEP-001).  
- **Why:** soft dependency — don’t page like SQL unless product says otherwise.

**A6 — Latency SLO**  
- **When:** warm Analyze **p95** stays above the local target (e.g. aspirational &lt;5s in supplemental SLOs) for a sustained window under modest load.  
- **Why:** LOAD studies showed capacity/tail issues; escalate to page only if sustained + user impact.

**A7 — Qdrant search health** (optional)  
- **When:** direct search error rate &gt; 0 or RPS collapses vs baseline under known pressure (PERF-003).  
- **Why:** PERF-003 showed **no** failure cliff at 64 concurrent in lab — so this is a *watch*, not a default page.

---

## Do **not** alert on (false friends)

| Symptom | Why not |
|---------|---------|
| Single Analyze ~15 s with `retrieval` ~80 ms | Bottleneck is elsewhere (imports / corrector / SQL / queue) — PERF-003 |
| First Qdrant searches ~300 ms after idle | Warmup (seen on c=8 tier) — not an outage |
| Auditor judge timeout with Ollama up | Config / cold model (REL-002) — fix timeout; don’t treat as “Ollama dead” |
| UI shell still loads during SQL outage | Expected — only Analyze/diag in blast radius (REL-004) |

---

## How this maps to tools you already have

| Tool | Role in alerting |
|------|------------------|
| **curl `/health`** | A2 |
| **Analyze HTTP status** | A1 |
| **Terminal DB check** | A3 |
| **Auditor status text** | A4 |
| **`policy_support` / Jaeger `retrieved_chunk_count`** | A5 |
| **Locust p95** | A6 |
| **Jaeger `cxr-qdrant-pressure` / CSV** | A7 / prove Qdrant not at fault |
| **Prometheus/Grafana** (when wired) | Same signals as time series — see [prometheus.md](../../archive/investigations-supplemental/prometheus.md) |

---

## Suggested first wiring (local)

1. **Blackbox:** loop curl Analyze + `/health` + SQL probe every 30–60s; alert script on consecutive fails → covers A1–A3.  
2. **Log/metric:** count Auditor connect errors → A4.  
3. **Later:** PromQL on request latency histogram for A6 once metrics are scraped.

---

## Bottom line

- **Page** when users **cannot analyze** (SQL / analyzer).  
- **Ticket** when the product is **degraded** (Ollama Auditor, Qdrant fallback).  
- **Don’t** page on “Analyze feels slow” without checking whether Qdrant/`retrieval` is actually the problem.

Technical index: [README.md](./README.md)

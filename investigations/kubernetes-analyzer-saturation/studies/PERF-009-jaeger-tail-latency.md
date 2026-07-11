# PERF-009 — Jaeger tail latency attribution (PERF-008 A vs B)

| | |
|---|---|
| **Status** | Complete (2026-06-22) |
| **Builds on** | [PERF-008](PERF-008-queue-depth-autoscaling.md) — Experiment A (p95 KEDA) and B (inflight/pod KEDA) |
| **Goal** | Name the **span** responsible for p95 E2E growth (~150 ms → ~800 ms @ 200 users) |
| **Ops scripts** | `cxr-ops-lab/scripts/perf009-jaeger-attribution.sh`, `scripts/lib/perf009_jaeger_extract.py` |
| **Evidence** | [perf009/](../evidence/perf009/) |

---

## Answer (read this first)

At 200 synthetic users, **most requests stay fast** (~40–150 ms) while **p95 climbs to ~800 ms**. Jaeger shows the tail is **not** slow LLM or retrieval.

On a typical **slow** request, the UI opens `fetch POST http://cxr-analyzer` and keeps it open for **~800 ms**, but the analyzer only runs `analyze_request` for **~30–60 ms** — and that work **starts hundreds of milliseconds late**. The gap is **client-visible wait** before the analyzer accepts the request, not slow kernel stages.

**Experiment B (inflight KEDA) did not change this pattern.** Scaling added replicas; it did not remove the UI→analyzer handoff wait that dominates p95.

**Named follow-up:** [SCALE-003 — UI bottleneck at peak load](SCALE-003-ui-bottleneck.md) ties this wait to the GATE-002 / PERF-008 UI thrash evidence.

---

## How to read this document

| Section | Audience | Content |
|---------|----------|---------|
| [Walkthrough — one fast, one slow trace](#walkthrough--one-fast-one-slow-trace) | Everyone | Screenshots + gap table — the “aha” moment |
| [Verdict](#verdict) | Reviewers | Hypothesis table + what to do next |
| [Automated replay — Experiments A & B](#automated-replay--experiments-a--b) | Deep dive | 3 fast + 3 slow traces per helm profile, median tables |
| [OBS-003 — Jaeger SQL errors](#obs-003--jaeger-sql-errors-separate-finding) | Ops | Policy span errors — **not** the 649 ms wait · **full write-up:** [OBS-003-shared-sql-connection.md](OBS-003-shared-sql-connection.md) |
| [Reproduce](#reproduce) | Lab | Scripts to re-run attribution |

---

## Background

[PERF-008](PERF-008-queue-depth-autoscaling.md) measured **p50 ~100–150 ms** and **p95 ~790–820 ms** at 200 users, and rejected inflight/pod KEDA as a scaling signal. It did not explain **which part of the path widens the tail**.

PERF-009 compares **fast** (~100–200 ms) vs **slow** (~700–900 ms) `POST` traces from the same load windows and checks whether Experiment B changed the slow-span fingerprint vs A.

---

## Walkthrough — one fast, one slow trace

Manual Jaeger review during load (**2026-06-22 ~11:28 local**). Same service, same operation, same second — only duration differs.

### Side-by-side numbers

| | Fast (p50-ish) | Slow (p95-ish) |
|---|----------------|----------------|
| **Trace ID** | `fd42f1c` | `f541546` |
| **E2E** | **40.7 ms** | **824 ms** |
| **`fetch` → analyzer** | ~36 ms | **818 ms** (starts ~3 ms into the trace) |
| **`analyze_request`** | ~30 ms | **~57 ms**, starts **~652 ms** after trace start |
| **Pre-handler gap** | ~0 ms | **~649 ms** |

### What the slow trace looks like on the timeline

```
0 ms          652 ms                              824 ms
|-------------|====================================|
 fetch open   (waiting — no analyzer work yet)     analyze_request ~57 ms
```

On the **fast** trace, `fetch` and `analyze_request` overlap — almost all time is real analyzer work.

On the **slow** trace, the blue `fetch` bar spans the full request; orange analyzer spans appear only at the **end**.

### Screenshots

**Fast trace (40.7 ms)** — `fetch` and `analyze_request` aligned:

![Fast trace — 40.7 ms E2E; fetch and analyze_request overlap](../evidence/perf009/jaeger-fast-trace-fd42f1c-41ms-20260622.png)

**Slow trace (824 ms)** — full waterfall; handler work is a short block at the end:

![Slow trace — 824 ms E2E; analyzer work only at the end](../evidence/perf009/jaeger-slow-trace-f541546-824ms-20260622.png)

**Slow trace (detail)** — `fetch` 818 ms; `analyze_request` starts at ~652 ms:

![Slow trace detail — 649 ms pre-handler wait before analyze_request](../evidence/perf009/jaeger-slow-fetch-wait-gap-20260622.png)

> **Note on Jaeger Compare:** Search → select two traces → **Compare** is useful in the live UI but exports poorly to static images (compressed table). Use the waterfalls above and the gap table for documentation. In the lab: service `cxr-ui-k8`, operation `POST`, traces `fd42f1c` / `f541546` around 11:28.

### Walkthrough takeaways

1. **Tail = a minority of requests** where the UI keeps `fetch` open while the analyzer **starts the handler late** — not a uniform slowdown of every stage.
2. **Analyzer work stays ~30–60 ms** even on the 824 ms trace; the **~649 ms gap** is queue/wait before `analyze_request`.
3. **[OBS-003](#obs-003--jaeger-sql-errors-separate-finding) policy SQL errors** (when present) sit **inside** the short analyzer window — they pollute Jaeger badges but **do not explain** the pre-handler gap.

All artifacts: [evidence/perf009/](../evidence/perf009/).

---

## Verdict

| Hypothesis | Result |
|------------|--------|
| **HTTP/client wait** (UI `fetch` open before handler starts) | **Primary** — ~550–665 ms median added wait on slow vs fast traces; ~649 ms on canonical pair |
| **Analyzer internal work** (`context_builder`, policy, archetype) | **Secondary** — +30–40 ms typical; occasional **200+ ms** outliers |
| **LLM / retrieval / Qdrant** | **Not implicated** — `retrieval` and `llm_inference` ≈ 0 ms in sampled traces |
| **Missing instrumentation** | **No gap** — wait appears *between* `fetch` wall time and `analyze_request` start |
| **Experiment B vs A** | **Same fingerprint** — inflight KEDA did not shift tail attribution |

**Why Prometheus `queue_wait` misled us:** that histogram measures **post-accept handler queue** on the analyzer (~1 ms p95 in PERF-008). Jaeger’s `fetch` − `analyze_request` gap captures **client-side wait before accept** — what Locust p95 actually sees.

**Why inflight KEDA (B) did not fix p95:** scaling added capacity, but the dominant tail is connection/handoff wait at the **UI→analyzer** boundary — not a signal KEDA was tuned to reduce.

### Conclusions

1. **p95 tail at 200 users = HTTP/client wait** on UI→analyzer `POST`, not LLM or retrieval.
2. **Secondary:** longer `context_builder` + policy + `archetype_reasoning` on some slow traces.
3. **PERF-008 decision stands:** keep p95 + CPU KEDA; use inflight/wait for diagnosis only.
4. **Next work:** connection pooling / analyzer admission and `context_builder` profiling — not another autoscaling signal swap.

---

## Automated replay — Experiments A & B

Original PERF-008 gate traces are **not** in Jaeger retention. Attribution replay used the same Helm overlays (`values-perf008-exp-a.yaml` / `values-perf008-exp-b.yaml`), `perf008` image, and a comparable @200-user soak (ramp 25→200, 45 s/tier, 4 min @200).

### Time windows

| Run | Window (UTC) | Gate p95 @200 | Notes |
|-----|----------------|---------------|-------|
| PERF-008 Exp A (original) | 2026-06-21 18:44 → 18:46 | **790 ms** | No Jaeger retention |
| PERF-008 Exp B (original) | 2026-06-22 03:40 → 03:42 | **820 ms** | No Jaeger retention |
| PERF-009 replay A | 2026-06-22 14:23 → 14:33 | **1000 ms** | 3 fast + 3 slow traces |
| PERF-009 replay B | 2026-06-22 14:36 → 14:46 | **900 ms** | 3 fast + 3 slow traces |

Gate evidence: `cxr-ops-lab/evidence/perf008/`. Replay: `cxr-ops-lab/evidence/perf009/`.

### Method

1. Service **`cxr-ui-k8`**, operation **`POST`** (same path as Grafana p95).
2. **Fast bucket:** 80–250 ms E2E → 3 traces nearest 150 ms.
3. **Slow bucket:** 600–1200 ms E2E → 3 traces nearest 800 ms.
4. Median span breakdown across 3 traces per bucket.

| Span | How it is measured |
|------|-------------------|
| UI POST (E2E) | Root `POST` span |
| UI → analyzer | `fetch POST http://cxr-analyzer` |
| **HTTP/client wait** | `fetch` duration − `analyze_request` duration |
| Analyzer work | `analyze_request`, `context_builder`, `context.7_policy*`, `archetype_reasoning`, `retrieval`, LLM spans |

Use **full 32-char trace IDs** in Jaeger 2.19.0 ([OBS-001 lesson](../evidence/load-observe/RUN-2026-06-17.md)).

### Experiment A — symptom KEDA (p95 + CPU)

| Class | Trace ID | E2E (ms) |
|-------|----------|----------|
| Fast | `3d11d4847b117c20359447a64fdf0802` | 148 |
| Fast | `9cbe002e33bf57f06c419d8627f5e8f0` | 153 |
| Fast | `1be230468cb9f4df44b9bfa775a06d7b` | 146 |
| Slow | `557390ac4a4b2323329f145b139754d6` | 794 |
| Slow | `93b84623af877ee2247cb830e0625ad7` | 794 |
| Slow | `10efc4868b2ee1648123fa359fcfc32b` | 792 |

**Median span table — A**

| Span | Fast | Slow | Δ |
|------|------|------|---|
| UI POST (E2E) | 148 | **794** | **+646** |
| HTTP/client wait | 48 | **665** | **+617** |
| `analyze_request` | 93 | 121 | +28 |
| `context_builder` | 27 | 59 | +32 |
| Policy / archetype | ~24 | ~59 | +35 |
| LLM / retrieval | 0 | 0 | 0 |

### Experiment B — inflight/pod KEDA + CPU

| Class | Trace ID | E2E (ms) |
|-------|----------|----------|
| Fast | `7b3613882ef5231127f6e8e4d5046db8` | 148 |
| Slow | `ff08d38c3fa1cda7ef10f008c4104a29` | 1022 |
| … | See [exp-b-jaeger-attribution.json](../evidence/perf009/exp-b-jaeger-attribution.json) | |

**Median span table — B**

| Span | Fast | Slow | Δ |
|------|------|------|---|
| UI POST (E2E) | 148 | **792** | **+644** |
| HTTP/client wait | 109 | **674** | **+565** |
| `analyze_request` | 30 | 103 | +73 |
| `context_builder` | 4 | 39 | +35 |
| LLM / retrieval | 0 | 0 | 0 |

### A vs B — slow traces compared

| Span | A slow | B slow | B − A |
|------|--------|--------|-------|
| E2E | 794 ms | 792 ms | −2 |
| HTTP/client wait | **665 ms** | **674 ms** | +9 |
| `analyze_request` | 121 ms | 103 ms | −18 |

**Same story in both experiments:** slow requests are wait-dominated; B does not change the attribution pattern.

---

## OBS-003 — Jaeger SQL errors (separate finding)

While reviewing slow traces, many showed **“2 Errors”** on `context.7_policy` / `context.7_policy.sql`. These are **not** the p95 tail mechanism.

**Full write-up (mechanism, architecture, before/after code, verification):** [OBS-003-shared-sql-connection.md](OBS-003-shared-sql-connection.md)

| Span | Error |
|------|--------|
| `context.7_policy.sql` | `pyodbc.Error: Connection is busy with results for another command` |

**Cause (one line):** one shared `pyodbc` connection per pod kernel singleton; up to **4 concurrent** `/analyze` threads opened cursors without a lock.

**Fix:** [issue #33](https://github.com/UdonsiKalu/cxr-portfolio/issues/33) · [cxr-platform PR #8](https://github.com/UdonsiKalu/cxr-platform/pull/8) — `threading.Lock` + `_db_cursor()`; image `cxr-analyzer:perf009-sql`. Verified **0** policy span errors post-fix. Screenshots: [evidence/obs003/](../evidence/obs003/).

> Keep **fetch-wait tail** and **SQL concurrency** as separate findings. SQL errors occur inside the short `analyze_request` window; they do not explain the ~649 ms pre-handler gap.

---

## Reproduce

```bash
cd ~/staging/cxr-ops-lab
./scripts/23-k8-load-observe-up.sh
./scripts/perf009-jaeger-attribution.sh a   # then b
```

JSON output: [exp-a-jaeger-attribution.json](../evidence/perf009/exp-a-jaeger-attribution.json), [exp-b](../evidence/perf009/exp-b-jaeger-attribution.json).

---

## Related

- [PERF-008](PERF-008-queue-depth-autoscaling.md) — KEDA A/B decision
- [OBS-001 run](../evidence/load-observe/RUN-2026-06-17.md) — `context_builder` at higher HPA caps
- [context-builder optimization (planned)](../../planned/context-builder-optimization.md)

# Kill analyzer under traffic (CHAOS-001)

| | |
|---|---|
| **Status** | Complete |
| **ID** | CHAOS-001 |
| **Component** | Warm FastAPI analyzer `:8766` under Locust load |
| **Tools** | Locust · health endpoint · Jaeger (optional) |
| **Builds on** | [LOAD-001](../single-analyzer-capacity/) · [LOAD-002](../analyzer-saturation/) |
| **Environment** | Local dev (`cxr up`, `ANALYZER_URL` → `:8766`) |

---

## Question

What happens when the analyzer (`:8766`) dies during analyze requests, and how long until the stack recovers to **`warmed: true`**?

## Hypothesis

Under moderate load (**5** users), killing the analyzer causes **5xx / fetch failed** errors until restart; recovery includes **~7s cold boot** plus warm steady-state; post-recovery p95 should match LOAD-001 (~**1.5s**).

## Method

1. `cxr up` — analyzer **`warmed: true`**, rehearsal `:8251` up.
2. Locust **5** users, POST `/api/claim-studio/analyze` only.
3. After **15s** baseline, **`fuser -k 8766/tcp`** (kill analyzer).
4. Hold **10s** outage, restart analyzer, poll `/health` until **`warmed: true`**.
5. Continue load through recovery; record failures, recovery time, post-outage p95.

Automated: [`run-kill-analyzer-chaos.sh`](./run-kill-analyzer-chaos.sh)  
Manual (screenshots): [`run-chaos-locust-gui.sh`](./run-chaos-locust-gui.sh) + [`kill-analyzer.sh`](./kill-analyzer.sh) + [`restart-analyzer-wait-warm.sh`](./restart-analyzer-wait-warm.sh)

---

## Run

```bash
cxr up
curl -s http://127.0.0.1:8766/health   # warmed: true

# Automated (timeline + summary in results/)
./investigations/kill-analyzer-under-traffic/run-kill-analyzer-chaos.sh

# GUI — for Locust Charts screenshot
./investigations/kill-analyzer-under-traffic/run-chaos-locust-gui.sh
# Start → wait ~30s → kill-analyzer.sh → restart-analyzer-wait-warm.sh → Stop
```

---

## Results (2026-06-05 — automated run)

Timeline: [`results/kill-chaos-timeline.log`](./results/kill-chaos-timeline.log)

| Metric | Value |
|--------|------:|
| Locust users | **5** |
| Total requests | **501** |
| Failures | **64** (**~12.8%**) |
| Failure window | ~**20s** (during outage only) |
| Error type | **500** — `Failed to analyze claim` / `fetch failed` |
| Kill → **`warmed: true`** | **~22s** |
| Health after restart | **~10s** |
| Warm after health | **~1s** (already booted; `warmed` flag set) |
| Post-recovery p95 | **~1.5s** (in line with LOAD-001) |
| Post-recovery median | **~1.1s** |

### Timeline (local)

| Time | Event |
|------|--------|
| T+0s | Locust **5** users started |
| T+15s | Analyzer killed (`:8766`) |
| T+18s | Analyzer down confirmed |
| T+28s | Restart initiated |
| T+37s | `/health` responding |
| T+37s | **`warmed: true`** |
| T+28–48s | **64** Locust failures (500) |
| T+120s+ | Steady success; p95 ~**1.5s** |

---

## Findings

1. **Failure mode is explicit** — Next.js returns **500** with `fetch failed` when `:8766` is unreachable; Locust counts failures cleanly.
2. **Blast radius is analyze path only** — rehearsal UI stays up; only analyze POSTs fail during outage.
3. **Recovery ~22s kill-to-warm** on this machine — dominated by analyzer restart + boot; not full **7s** re-import if process respawns quickly with warm singleton.
4. **No lingering degradation** — after warm, p95 returns to LOAD-001 band (~**1.5s**).
5. **Client timeout matters** — use **30s** request timeout in chaos locustfile so headless runs finish on schedule (120s default hung with 120s timeouts).

---

## Decision

- Document **kill → 500 errors ~20s → ~22s recovery** as local single-analyzer resilience baseline.
- For production: health-check + restart policy; consider circuit breaker on `:8251` → `:8766` after repeated fetch failures.
- Re-run GUI path for portfolio **screenshot** of failure spike + recovery (optional).

---

## Follow-up

- [qdrant-outage/](../qdrant-outage/) — dependency failure (different blast radius)
- [trace-propagation/](../trace-propagation/)

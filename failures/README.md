# Failures and reverted paths

An honest index of **what did not work** or **what we tried and rejected**. Failures are linked to evidence — not hidden, not repeated as long prose here.

> “Document mistakes and reverted paths — they are as valuable as wins.” — [CHANGELOG](../CHANGELOG.md)

---

## Load and performance

| Date | What failed | Why | Evidence | Screenshot / chart |
|------|-------------|-----|----------|-------------------|
| 2026-06-22 | PERF-008 **Experiment B** @ 200 users | Inflight/pod KEDA scaled to 8 but **115 failures/s** (`status 0`) — rejected as scaling signal | [PERF-008 doc](../docs/PERF-008-queue-depth-autoscaling.md) · `cxr-ops-lab/evidence/perf008/exp-b-20260622-034010/` | Grafana: add PNGs under [evidence/perf008/](../investigations/kubernetes-analyzer-saturation/evidence/perf008/) (see note below) |
| 2026-06-21 | PERF-008 Experiment A (first run) | Metrics layer built but pods kept cached `perf003` image — **no analyzer `/metrics`** in Prometheus for that window | [PERF-008 doc](../docs/PERF-008-queue-depth-autoscaling.md) · `exp-a-20260621-174522/` | — |
| 2026-06-19 | GATE-002 **candidate 1** (1/12 recipes) | UI `maxReplicas=5` + analyzer `minReplicas=1` → **116 failures/s** @ 200 users | [result-c1](../investigations/kubernetes-analyzer-saturation/results/tuner/result-c1-20260619-080505.json) | — |
| 2026-06-19 | Lightweight mixed tuner (`072020`) | Not OBS-comparable; UI-only bottleneck — archived | [lightweight-mixed-072020/](../investigations/kubernetes-analyzer-saturation/results/tuner/lightweight-mixed-072020/) | — |
| 2026-06-18 | Full **0→200** ramp after PERF-003 | **18×** replica collapses (8→1), **~132 failures/s**, sawtooth RPS, UI at **5/5** | [load-20260618-064836.csv](../investigations/kubernetes-analyzer-saturation/results/load-20260618-064836.csv) | [load-test-autoscaling](../investigations/kubernetes-analyzer-saturation/screenshots/load-test-autoscaling.png) |
| 2026-06-18 | Analyzer **maxReplicas: 20** | **20→1** collapses, **6 pending** pods; node CPU still **~8–15%** | [load-20260618-060419.csv](../investigations/kubernetes-analyzer-saturation/results/load-20260618-060419.csv) | [locust-hpa-final-200users](../investigations/kubernetes-analyzer-saturation/screenshots/locust-hpa-final-200users.png) |
| 2026-06-17 | OBS-001 full ramp @ 200 users | **p95 ~9s**, volatile RPS, analyzer pending, HPA thrash — not host CPU saturation | [RUN-2026-06-17](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) | [grafana problem summary](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/grafana-load-003-problem-summary.png) |
| 2026-06-08 | LOAD-003b **maxReplicas 20/20** | Worse than **8/5** caps on single node — scheduling thrash | `load-20260608-182451.csv` vs `load-20260608-125236.csv` | [locust-hpa-mid-50users](../investigations/kubernetes-analyzer-saturation/screenshots/locust-hpa-mid-50users.png) |
| 2026-06 (LOAD-002) | Single-process saturation | Tail latency runaway to **~225 users**; **~15–16 RPS** ceiling (0% hard failures) | [analyzer-saturation](../investigations/analyzer-saturation/README.md) | [locust continuous ramp](../investigations/analyzer-saturation/screenshots/locust-continuous-ramp-225users-saturation.png) |

**Contrast (success):** GATE-002 winner [candidate 4](../investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json) — **102 RPS**, **0 failures**, p95 **~820ms** @ 200. PERF-008 Experiment A (re-run): **101 RPS**, p95 **790 ms**, **0 failures** @ 200.

---

## Latency and architecture (superseded paths)

| Date | What failed | Why | Evidence | Screenshot / chart |
|------|-------------|-----|----------|-------------------|
| 2026-05–06 | Subprocess-per-request analyze | **~10–12s** Locust p95; **~7–8s** Python import/init every request | [python-import-bottleneck](../investigations/postmortems/python-import-bottleneck.md) · [ADR-003](../architecture/adrs/ADR-003-python-subprocess.md) | [before Locust 11s p95](../investigations/load-testing/screenshots/before-locust-post-analyze-11s-p95-2026-06-01.png) · [Jaeger import 7s](../investigations/latency-investigation/screenshots/before-jaeger-python-module-import-7s-2026-06-01.png) |
| 2026-05–06 | “Kernel is slow” hypothesis | Profiling showed kernel **~1.5s** once warm; subprocess was the cost | [latency-investigation](../investigations/latency-investigation/README.md) | [Jaeger waterfall 11s / 5 spans](../investigations/latency-investigation/screenshots/before-jaeger-waterfall-11s-5spans-2026-05-30.png) |

**Superseded by:** [ADR-004 long-running analyzer](../architecture/adrs/ADR-004-long-running-analyzer.md) — warm p95 **~1.5s**; traces **~154–708ms** ([after warm trace](../investigations/latency-investigation/screenshots/after-jaeger-locust-154ms-22spans-2026-06-02.png)).

---

## Operations and GitOps

| Date | What failed | Why | Evidence | Screenshot / chart |
|------|-------------|-----|----------|-------------------|
| 2026-06-18 | Local Helm tuning overwritten | Argo CD **auto-sync + selfHeal** from `main` with stale values | [CHANGELOG](../CHANGELOG.md) (Argo entry) | — |
| 2026-06 (open) | GIT-001 values drift | Winner GATE-002 caps not yet on git-managed `main` | [Issue #24](https://github.com/UdonsiKalu/cxr-portfolio/issues/24) | — |

---

## Reliability and chaos

| Date | What failed | Why | Evidence | Screenshot / chart |
|------|-------------|-----|----------|-------------------|
| 2026-06 | Kill analyzer under traffic (CHAOS-001) | **500** / `fetch failed` for **~64** requests until cold restart (~7s boot) | [kill-analyzer-under-traffic](../investigations/kill-analyzer-under-traffic/README.md) | Optional: [screenshots folder](../investigations/kill-analyzer-under-traffic/screenshots/README.md) |

*Qdrant outage (DEP-001) did **not** fail HTTP — analyzer returned **200** with degraded retrieval ([qdrant-outage](../investigations/qdrant-outage/README.md)).*

---

## Observability and methodology

| Issue | Impact | Mitigation | Screenshot / chart |
|-------|--------|------------|-------------------|
| Analyzer replicas **0** in LOAD CSV/Grafana (OBS-002) | Could not trust replica lines during KEDA runs | **Resolved** — Deployment readyReplicas in exporter ([PERF-008](../docs/PERF-008-queue-depth-autoscaling.md)) | Use **KEDA replicas vs backpressure** panel, not cluttered top scaling panel |
| Grafana HPA “125 replicas” misread | Confusion during early K8 runs | Read **replica** series on **right** axis (0–8), not CPU % | — |
| Jaeger compare: startup vs POST mixed | Invalid conclusions from overlaying unlike operations | Documented pairs in OBS-001 runbook | [invalid compare](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/jaeger-compare-startup-vs-post-invalid.png) · [wrong operation mix](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/jaeger-compare-wrong-operation-mix.png) |
| Jaeger short trace ID → 404 | Lost time in UI | Use full trace ID from search | [404 short id](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/jaeger-compare-404-short-trace-id.png) |
| Discrete load stages (early tuner) | Over-optimistic vs cumulative ramp | GATE-002 cumulative ramp | — |
| Locust p95 vs single Jaeger trace | Comparing unlike metrics | Documented in investigations README | — |
| Load CSV has no `context_builder` column | Tail attribution requires Jaeger | PERF-009 planned; optional OTLP→Prometheus later | [context_builder 7s](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/jaeger-post-7s-context-builder.png) |
| Missing / minimal trace profiles | Hid startup and `context_builder` cost | Reject minimal Jaeger profiles under load | [postmortem: jaeger trace profile](../investigations/postmortems/jaeger-trace-profile.md) |

---

## Visual evidence index (by theme)

### Grafana — load and HPA failure shapes

| Image | Run / theme |
|-------|-------------|
| [grafana-load-003-problem-summary.png](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/grafana-load-003-problem-summary.png) | OBS-001 — p95 to ~9s, pending pods, low node CPU |
| [grafana-load-003-2x2-live.png](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/grafana-load-003-2x2-live.png) | OBS-001 mid-ramp |
| [locust-hpa-final-200users.png](../investigations/kubernetes-analyzer-saturation/screenshots/locust-hpa-final-200users.png) | Early K8 — HPA at caps |
| [load-test-autoscaling.png](../investigations/kubernetes-analyzer-saturation/screenshots/load-test-autoscaling.png) | Jun 18 instability chart |

### Jaeger — tail latency and mistakes

| Image | Run / theme |
|-------|-------------|
| [jaeger-post-7s-context-builder.png](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/jaeger-post-7s-context-builder.png) | OBS-001 — slow `context_builder` |
| [jaeger-startup-17s-waterfall.png](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/jaeger-startup-17s-waterfall.png) | Cold start ~15–17s per pod |
| [jaeger-compare-startup-pair.png](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/jaeger-compare-startup-pair.png) | Valid startup compare |
| [jaeger-compare-post-pair.png](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/jaeger-compare-post-pair.png) | Fast vs slow POST pair |

### Subprocess era (before ADR-004)

| Image | Run / theme |
|-------|-------------|
| [before-locust-post-analyze-11s-p95-2026-06-01.png](../investigations/load-testing/screenshots/before-locust-post-analyze-11s-p95-2026-06-01.png) | ~11s median POST |
| [before-jaeger-python-module-import-7s-2026-06-01.png](../investigations/latency-investigation/screenshots/before-jaeger-python-module-import-7s-2026-06-01.png) | Import span dominates |
| [after-jaeger-locust-154ms-22spans-2026-06-02.png](../investigations/latency-investigation/screenshots/after-jaeger-locust-154ms-22spans-2026-06-02.png) | After warm analyzer (contrast) |

### PERF-008 (add screenshots)

Save full-page Grafana captures from Experiments A and B into:

`investigations/kubernetes-analyzer-saturation/evidence/perf008/`

Suggested names: `grafana-perf008-exp-a-load.png`, `grafana-perf008-exp-a-backpressure.png`, `grafana-perf008-exp-b-failures.png`. CSV and JSON remain in `cxr-ops-lab/evidence/perf008/`.

---

## Related

- [docs/history.md](../docs/history.md) — arcs with failures in context  
- [CHANGELOG.md](../CHANGELOG.md) — dated journal (all entries above have matching rows)  
- [docs/postmortems/README.md](../docs/postmortems/README.md) — full incident write-ups  
- [reliability/SLO.md](../reliability/SLO.md) — gate pass is not the same as production SLO

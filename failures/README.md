# Failures and reverted paths

An honest index of **what did not work** or **what we tried and rejected**. Failures are linked to evidence — not hidden, not repeated as long prose here.

> “Document mistakes and reverted paths — they are as valuable as wins.” — [CHANGELOG](../CHANGELOG.md)

---

## Load & performance

| Date | What failed | Why | Evidence |
|------|-------------|-----|----------|
| 2026-06-18 | Full **0→200** ramp after initial PERF-003 fix | Replica collapses, **~132 failures/s**, UI bottleneck, HPA thrash | [CHANGELOG](../CHANGELOG.md) · [load-20260618-064836.csv](../investigations/kubernetes-analyzer-saturation/results/load-20260618-064836.csv) |
| 2026-06-18 | **maxReplicas: 20** analyzer | Scheduling pressure, **20→1** collapses, pending pods; node CPU still low | [CHANGELOG](../CHANGELOG.md) · [load-20260618-060419.csv](../investigations/kubernetes-analyzer-saturation/results/load-20260618-060419.csv) |
| 2026-06-19 | GATE-002 **candidate 1** only (1/12) | UI `maxReplicas=5` + analyzer `minReplicas=1` → **116 failures/s** @ 200 users | [result-c1](../investigations/kubernetes-analyzer-saturation/results/tuner/result-c1-20260619-080505.json) |
| 2026-06-19 | Lightweight mixed tuner profile (`072020`) | Not OBS-comparable; UI-only bottleneck — archived, not used for winner | [lightweight-mixed-072020/](../investigations/kubernetes-analyzer-saturation/results/tuner/lightweight-mixed-072020/) |

**Contrast (success):** GATE-002 winner [candidate 4](../investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json) — **102 RPS**, **0 failures**, p95 **~820ms** @ 200.

---

## Operations & GitOps

| Date | What failed | Why | Evidence |
|------|-------------|-----|----------|
| 2026-06-18 | Local Helm tuning overwritten | Argo CD auto-sync from `main` with stale values | [CHANGELOG — Argo](../CHANGELOG.md) |

---

## Architecture (superseded)

| Decision | Superseded by | Notes |
|----------|---------------|-------|
| Subprocess-per-request analyzer | [ADR-004](../architecture/adrs/ADR-004-long-running-analyzer.md) | [ADR-003](../architecture/adrs/ADR-003-python-subprocess.md) historical |

---

## Observability & methodology

| Issue | Impact | Mitigation |
|-------|--------|------------|
| Analyzer replicas **0** in LOAD CSV/Grafana | Cannot attribute tail to analyzer scale in dashboard | Open: fix KEDA replica polling in exporter |
| Discrete load stages (early tuner) | Over-optimistic vs cumulative ramp | Replaced with cumulative ramp in GATE-002 |
| Locust p95 vs Jaeger single trace | Comparing unlike metrics | Documented in investigations README |

---

## How to add an entry

1. One row in the right table above.  
2. Matching dated entry in [CHANGELOG](../CHANGELOG.md).  
3. Link to CSV, JSON, screenshot, or run doc — not a duplicate essay.

---

## Related

- [docs/history.md](../docs/history.md) — arcs with failures in context  
- [docs/postmortems/README.md](../docs/postmortems/README.md) — full incident write-ups  
- [reliability/SLO.md](../reliability/SLO.md) — gate pass ≠ strict product SLO

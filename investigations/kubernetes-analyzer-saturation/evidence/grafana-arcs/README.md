# Grafana arc screenshots (file catalog)

<!-- portfolio -->

Narrative write-up for reviewers: **[failures/README.md](../../../../failures/README.md)** — read that first.

This folder holds Grafana captures for arcs 2–5 (OBS-001, Jun 18 regressions, GATE-002 tuner, etc.). It used to be named `evidence/failures/` — renamed so it is not confused with the root **failures** story page. PERF-008 screenshots live in [../perf008/](../perf008/README.md).

| File | Run / theme |
|------|-------------|
| [grafana-obs-001-full-run-20260617.png](grafana-obs-001-full-run-20260617.png) | OBS-001 — full ramp, analyzer thrash |
| [grafana-jun18-maxreplicas20-collapse.png](grafana-jun18-maxreplicas20-collapse.png) | Jun 18 — replicas 20→0 |
| [grafana-jun18-post-perf003-unstable.png](grafana-jun18-post-perf003-unstable.png) | Jun 18 — sawtooth RPS after cache |
| [grafana-jun18-hpa-thrash.png](grafana-jun18-hpa-thrash.png) | Jun 18 — UI replica oscillation |
| [grafana-jun18-pending-pods.png](grafana-jun18-pending-pods.png) | Jun 18 — pending scheduling pressure |
| [grafana-gate-c1-fail-20260619.png](grafana-gate-c1-fail-20260619.png) | GATE-002 c1 — 116 failures/s @ 200 |
| [grafana-gate-tuner-analyzer-replicas-zero.png](grafana-gate-tuner-analyzer-replicas-zero.png) | GATE tuner — flat analyzer replicas |
| [grafana-gate-tuner-multi-cycle-20260619.png](grafana-gate-tuner-multi-cycle-20260619.png) | GATE tuner — four cumulative ramps |
| [grafana-gate-tuner-run.png](grafana-gate-tuner-run.png) | GATE tuner — late-ramp failure window |
| [grafana-gate-tuner-run-2.png](grafana-gate-tuner-run-2.png) | GATE tuner — mid-ramp |
| [grafana-gate-tuner-run-3.png](grafana-gate-tuner-run-3.png) | GATE tuner — alternate window |

CSV/JSON for the same runs: `investigations/kubernetes-analyzer-saturation/results/` and `cxr-ops-lab/evidence/`.

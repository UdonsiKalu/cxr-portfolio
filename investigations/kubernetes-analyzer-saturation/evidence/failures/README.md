# Failure screenshots (Grafana LOAD-003)

Visual evidence for rows in [failures/README.md](../../../../failures/README.md). Source captures: `~/Pictures/Screenshots` (Jun 17–19, 2026).

| File | Run / failure | Source screenshot |
|------|---------------|-------------------|
| [grafana-obs-001-full-run-20260617.png](grafana-obs-001-full-run-20260617.png) | OBS-001 — p95 to ~9s, analyzer HPA thrash 2↔20, pending pods | `Screenshot from 2026-06-17 16-31-00.png` (full run window 15:36–16:38) |
| [grafana-jun18-maxreplicas20-collapse.png](grafana-jun18-maxreplicas20-collapse.png) | Jun 18 — analyzer replicas 20→0, failures spike | `Screenshot from 2026-06-18 06-24-19.png` |
| [grafana-jun18-hpa-thrash.png](grafana-jun18-hpa-thrash.png) | Jun 18 — UI replica oscillation 1↔6 | Same family as 06:24 run |
| [grafana-jun18-pending-pods.png](grafana-jun18-pending-pods.png) | Jun 18 — analyzer/ui pending under load | Jun 18 morning runs |
| [grafana-jun18-post-perf003-unstable.png](grafana-jun18-post-perf003-unstable.png) | Jun 18 post-PERF-003 — sawtooth RPS, ~132 failures/s | `Screenshot from 2026-06-18 08-37-04.png` (06:50–07:34) |
| [grafana-gate-tuner-analyzer-replicas-zero.png](grafana-gate-tuner-analyzer-replicas-zero.png) | GATE tuner — analyzer replicas flat, UI HPA thrash | `Screenshot from 2026-06-19 07-39-07.png` |
| [grafana-gate-tuner-run.png](grafana-gate-tuner-run.png) | GATE-002 candidate 1 — 116 failures/s @ 200 users | `Screenshot from 2026-06-19 09-28-26.png` |
| [grafana-gate-c1-fail-20260619.png](grafana-gate-c1-fail-20260619.png) | Same as above (canonical c1 fail capture) | `Screenshot from 2026-06-19 09-28-26.png` |
| [grafana-gate-tuner-run-2.png](grafana-gate-tuner-run-2.png) | GATE tuner — mid-ramp instability | Jun 19 tuner session |
| [grafana-gate-tuner-run-3.png](grafana-gate-tuner-run-3.png) | GATE tuner — late-ramp failure spike | Jun 19 tuner session |
| [grafana-gate-tuner-multi-cycle-20260619.png](grafana-gate-tuner-multi-cycle-20260619.png) | GATE tuner — four cumulative ramps, HPA thrash | `Screenshot from 2026-06-19 11-05-59.png` |

CSV/JSON for the same runs remain under `investigations/kubernetes-analyzer-saturation/results/` and `cxr-ops-lab/evidence/`.

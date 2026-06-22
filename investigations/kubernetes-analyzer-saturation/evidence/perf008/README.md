# PERF-008 evidence (Grafana screenshots)

Gate CSV, JSON, and summaries live in **`cxr-ops-lab/evidence/perf008/`** on branch `feature/perf-008-queue-backpressure`.

Study write-up: [docs/PERF-008-queue-depth-autoscaling.md](../../../../docs/PERF-008-queue-depth-autoscaling.md)

## Runs

| Run | Gate | Ops-lab evidence |
|-----|------|------------------|
| Experiment A (re-run) | PASS @ 200 users — 101 RPS, p95 790 ms, 0 failures | `exp-a-20260621-184452/` |
| Experiment B | FAIL @ 200 users — 115.8 failures/s (`status 0`) | `exp-b-20260622-034010/` |

## Screenshots

Source captures: `~/Pictures/Screenshots` (Jun 21–22, 2026).

### Experiment A (p95 + CPU KEDA)

| File | Content |
|------|---------|
| [grafana-perf008-setup-early-ramp.png](grafana-perf008-setup-early-ramp.png) | Early ramp — top LOAD-003 row |
| [grafana-perf008-exp-a-ramp-early.png](grafana-perf008-exp-a-ramp-early.png) | Mid setup before metrics layer |
| [grafana-perf008-exp-a-ramp-mid.png](grafana-perf008-exp-a-ramp-mid.png) | Ramp with scaling signals |
| [grafana-perf008-exp-a-load-full.png](grafana-perf008-exp-a-load-full.png) | Full run — users, RPS, p95, replicas 2→8 |
| [grafana-perf008-exp-a-load-end.png](grafana-perf008-exp-a-load-end.png) | End of gate window @ 200 users |
| [grafana-perf008-exp-a-load-alt.png](grafana-perf008-exp-a-load-alt.png) | Alternate full-run capture (Jun 22 review) |
| [grafana-perf008-exp-a-backpressure.png](grafana-perf008-exp-a-backpressure.png) | PERF-008 landscape row — inflight, wait, KEDA staircase |
| [grafana-perf008-exp-a-backpressure-alt.png](grafana-perf008-exp-a-backpressure-alt.png) | Alternate backpressure row |
| [grafana-perf008-exp-a-backpressure-nodata.png](grafana-perf008-exp-a-backpressure-nodata.png) | First pass — empty inflight/wait panels before `perf008` image |

### Experiment B (inflight/pod KEDA — rejected)

| File | Content |
|------|---------|
| [grafana-perf008-exp-b-load.png](grafana-perf008-exp-b-load.png) | Load row — failures spike ~115/s, UI HPA thrash |
| [grafana-perf008-exp-b-backpressure.png](grafana-perf008-exp-b-backpressure.png) | KEDA 2→8 staircase + E2E p95 climb to ~820 ms |

Link from [failures index](../../../../failures/README.md#load-and-performance).

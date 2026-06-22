# PERF-008 evidence (Grafana screenshots)

Gate CSV, JSON, and summaries live in **`cxr-ops-lab/evidence/perf008/`** on branch `feature/perf-008-queue-backpressure`.

## Runs

| Run | Gate | Evidence (ops-lab) |
|-----|------|-------------------|
| Experiment A | PASS @ 200 users | `exp-a-20260621-184452/` |
| Experiment B | FAIL @ 200 users (115 failures/s) | `exp-b-20260622-034010/` |

Study write-up: [docs/PERF-008-queue-depth-autoscaling.md](../../../../docs/PERF-008-queue-depth-autoscaling.md)

## Screenshots to add here

Export from Grafana LOAD-003 (`http://127.0.0.1:3001/d/cxr-hpa-load-003`) for each run time window:

| File (suggested) | Content |
|------------------|---------|
| `grafana-perf008-exp-a-load.png` | Top row — users, RPS, p95, scaling |
| `grafana-perf008-exp-a-backpressure.png` | PERF-008 landscape row + scrape health |
| `grafana-perf008-exp-b-load.png` | Experiment B — load + failure spikes |
| `grafana-perf008-exp-b-backpressure.png` | Experiment B — KEDA staircase + backpressure |

Link from [failures index](../../../../failures/README.md#load-and-performance).

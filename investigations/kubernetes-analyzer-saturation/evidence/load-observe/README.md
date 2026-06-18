# LOAD observe evidence (Grafana + Jaeger)

Artifacts from [`23-k8-load-observe-up.sh`](../../../../cxr-ops-lab/scripts/23-k8-load-observe-up.sh) runs.

## Runs

| Run | Doc | Highlights |
|-----|-----|------------|
| **2026-06-17** | [RUN-2026-06-17.md](./RUN-2026-06-17.md) | **[Problem summary](./grafana-load-003-problem-summary.png)** — full 0→200 run; Jaeger startup + POST; `context_builder` |
| 2026-06-08 | [../load-003/](../load-003/) | CSV + Locust screenshots (pre-unified Grafana) |

## How to add a new run

1. Start observe: `cd ~/staging/cxr-ops-lab && ./scripts/23-k8-load-observe-up.sh`
2. Run LOAD-003 ramp (see [K8-LOAD-OBSERVE-RUNBOOK.md](../../../../cxr-ops-lab/docs/K8-LOAD-OBSERVE-RUNBOOK.md))
3. Screenshot Grafana (`cxr-hpa-load-003`), Jaeger compares, Prometheus targets
4. Copy PNGs here; add `RUN-YYYY-MM-DD.md` with findings
5. Link from [kubernetes-analyzer-saturation README](../../README.md)

## Optional exports

| File | Source |
|------|--------|
| `jaeger-traces.json` | `./scripts/jaeger-k8-traces-snapshot.sh` |
| CSV + charts | `run-k8-load-with-metrics.sh` + `plot_load_test.py` |

## Screenshot naming

Use descriptive names: `grafana-*.png`, `jaeger-*.png`, `prometheus-*.png`. Index table lives in each run doc.

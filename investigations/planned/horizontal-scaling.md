# LOAD-003 — Horizontal scaling (1 vs N analyzers)

**Status:** Planned (Phase 2)

| Field | |
|-------|---|
| **Question** | Does adding analyzer instances improve Locust p95 linearly? |
| **Hypothesis** | TBD |
| **Method** | Run 1 vs 3 analyzer processes behind a load balancer |
| **Tools** | Locust, Jaeger |
| **Metrics** | p95, error rate, per-instance CPU |

## Results

Not yet run.

## Follow-up

Requires [single-analyzer-capacity](../single-analyzer-capacity/) saturation data and [load-balancing](./load-balancing.md).

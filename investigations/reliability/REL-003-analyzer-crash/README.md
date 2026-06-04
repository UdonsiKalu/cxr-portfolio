# REL-003 — Analyzer crash / recovery

**Status:** Planned (Phase 1)

## Question

After the analyzer dies under load, how do errors present and how long until steady-state analyze returns?

## Method

Run together with [CHAOS-001 — kill analyzer](../../chaos-experiments/CHAOS-001-kill-analyzer/):

1. Locust swarm during kill
2. Document error rate and user-visible failures
3. Restart analyzer (`cxr up` or service restart)
4. Measure recovery time and first successful warm trace in Jaeger

| Field | |
|-------|---|
| **Tools** | Locust, Jaeger, `curl :8766/health` |
| **Metrics** | Error % during outage; seconds to `warmed: true`; post-recovery p95 |

## Results

Not yet run.

## Follow-up

[REL-001](../REL-001-qdrant-outage/) — dependency failure (different blast radius).

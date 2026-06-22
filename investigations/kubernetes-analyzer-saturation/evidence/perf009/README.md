# PERF-009 — Jaeger tail latency evidence

Attribution replay for [PERF-009](../../../../docs/PERF-009-jaeger-tail-latency.md) (PERF-008 Experiment A vs B helm profiles).

| File | Experiment | Contents |
|------|------------|----------|
| [exp-a-jaeger-attribution.json](exp-a-jaeger-attribution.json) | A (p95 KEDA) | 3 fast + 3 slow traces, median span table |
| [exp-b-jaeger-attribution.json](exp-b-jaeger-attribution.json) | B (inflight KEDA) | Same |

Raw gate CSV and console logs: `cxr-ops-lab/evidence/perf009/exp-a-20260622-092152/`, `exp-b-20260622-093426/`.

Trace IDs in JSON include local Jaeger URLs (`http://127.0.0.1:16686/trace/<id>`) — valid when the observe stack is up.

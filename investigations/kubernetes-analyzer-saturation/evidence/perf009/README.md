# PERF-009 — Jaeger tail latency evidence

Attribution replay for [PERF-009](../../studies/PERF-009-jaeger-tail-latency.md) (PERF-008 Experiment A vs B helm profiles).

| File | Experiment | Contents |
|------|------------|----------|
| [exp-a-jaeger-attribution.json](exp-a-jaeger-attribution.json) | A (p95 KEDA) | 3 fast + 3 slow traces, median span table |
| [exp-b-jaeger-attribution.json](exp-b-jaeger-attribution.json) | B (inflight KEDA) | Same |
| `jaeger-fast-trace-fd42f1c-41ms-20260622.png` | Manual review | Fast waterfall — aligned `fetch` + `analyze_request` |
| `jaeger-slow-trace-f541546-824ms-20260622.png` | Manual review | Slow waterfall — 824 ms E2E, handler ~57 ms at end |
| `jaeger-slow-fetch-wait-gap-20260622.png` | Manual review | Slow trace detail — `fetch` 818 ms, `analyze_request` starts ~652 ms |

Raw gate CSV and console logs: `cxr-ops-lab/evidence/perf009/exp-a-20260622-092152/`, `exp-b-20260622-093426/`.

Trace IDs in JSON include local Jaeger URLs (`http://127.0.0.1:16686/trace/<id>`) — valid when the observe stack is up.

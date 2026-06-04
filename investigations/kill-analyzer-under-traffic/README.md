# Kill analyzer under traffic

**Status:** Planned (Phase 1)

**Covers:** fault injection (kill process during Locust) **and** recovery (time to warm steady state again).

## Question

What happens when the analyzer (:8766) dies during analyze requests, and how long until the stack recovers?

## Method (draft)

1. `cxr up` — warm analyzer, start Locust (3–5 users) on `POST /api/claim-studio/analyze`
2. Kill analyzer process or stop container mid-swarm
3. Record Locust error rate and UI/API behavior
4. Restart analyzer; poll `curl http://127.0.0.1:8766/health` until `"warmed":"true"`
5. Confirm post-recovery p95 and a linked Jaeger trace

| Tools | Locust, Jaeger, health endpoint |
| Metrics | Error % during outage; seconds to recovery; post-recovery p95 vs baseline |

## Results

Not yet run — add `screenshots/` when complete.

## Follow-up

[qdrant-outage](../qdrant-outage/) — dependency failure (different blast radius).

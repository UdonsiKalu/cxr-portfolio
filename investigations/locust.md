# Locust — load testing CXR

Quick reference for load testing Claim Studio. Full results: [load-testing/](./load-testing/).

## Setup

| Setting | Value |
|---------|-------|
| Tool | Locust (`cxr-ops-lab/load/locust`) |
| Target | `http://127.0.0.1:8251` (`CXR_LOAD_URL`) |
| UI | http://127.0.0.1:8089 |
| Observe | Jaeger http://127.0.0.1:16686 |

Start: `cxr up` or `cxr-ops-lab/scripts/22-load-locust.sh`.

## Primary scenario

**POST /api/claim-studio/analyze** — filter Jaeger by this operation, not GET page loads.

## Read with Jaeger

1. Swarm 3–5 users on :8089.
2. Jaeger → `cxr-ui-rehearsal` → `POST /api/claim-studio/analyze`.
3. Compare Locust p95 (client) vs single-trace duration in Jaeger — see [latency investigation](./latency-investigation/).

## Related

- [OpenTelemetry](./opentelemetry.md)
- [Jaeger](./jaeger.md)

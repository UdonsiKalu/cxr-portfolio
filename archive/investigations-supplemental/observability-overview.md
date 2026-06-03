# Observability overview

## Goals

1. **Prove** where time goes on `POST /api/claim-studio/analyze` (not guess from wall clock).
2. **Separate** one-time analyzer startup (~7s imports) from steady-state analyze (~1–3s).
3. **Correlate** Locust load tests with distributed traces in Jaeger.

## Stack

| Tool | Port | Role |
|------|------|------|
| OpenTelemetry SDK | — | Node + Python instrumentation |
| OTel Collector | 4318 | OTLP ingest, export to Jaeger |
| Jaeger | 16686 | Trace search and waterfall UI |
| Prometheus | 9090 | Metrics (bootcamp observe compose) |
| Grafana | 3001 | Dashboards (starter provisioning) |
| Locust | 8089 | Load generation against Claim Studio |

## Service names in Jaeger

| Service | What it represents |
|---------|-------------------|
| `cxr-ui-rehearsal` | Next.js dev UI on :8251 |
| `cxr-analyzer-service` | FastAPI warm analyzer on :8766 |

Filter **POST** operations for analyze work—not GET `/claim-studio` page loads.

## Golden path

1. `cxr up` (or manual observe + analyzer + UI + Locust)
2. Run analysis in Claim Studio **or** swarm Locust
3. Jaeger → Service → `POST /api/claim-studio/analyze` or `analyzer_service.analyze_request`
4. Open waterfall; read child spans (`context_builder`, `claim_analysis`, …)

## Deep dives

- [OpenTelemetry](../../investigations/opentelemetry.md)
- [Jaeger](../../investigations/jaeger.md)
- [Latency investigation](../../investigations/latency-investigation/latency-investigation.md)
- [Load testing results](../../investigations/load-testing/load-testing-results.md)

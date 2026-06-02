# OpenTelemetry

## What we instrumented

| Runtime | Entry | Key spans |
|---------|-------|-----------|
| Node (Next.js) | `instrumentation.ts` | `POST /api/claim-studio/analyze`, `claim_studio.*`, `analyzer.http.*` |
| Python (analyzer) | `otel_trace.py` | `analyzer_service.startup`, `analyzer_service.analyze_request`, kernel stages |

## Environment

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318
export OTEL_SERVICE_NAME=cxr-ui-rehearsal   # Next.js
# analyzer uses cxr-analyzer-service via start script
export CXR_TRACE_PROFILE=detailed
```

## OTLP vs Jaeger URL

- **OTLP** (`:4318`) — apps **send** spans (OpenTelemetry Protocol).
- **Jaeger UI** (`:16686`) — humans **view** traces after the collector stores them.

## Trace propagation

Next.js injects **W3C `traceparent`** on HTTP calls to the analyzer so one logical request appears as a **linked trace** across both services.

## Python startup flush

Batch exporters may not flush **startup-only** spans before the first HTTP request. `flush_tracing()` after analyzer lifespan ensures `analyzer_service.startup` appears in Jaeger.

## Profile: `detailed` vs `minimal`

Default **`detailed`** — nested spans per pipeline stage (`context_builder`, `retrieval`, …).

**`minimal`** was rejected: more confusing Operations list, fewer spans, worse investigations.

# ADR-002: OpenTelemetry for CXR local platform

## Status

Accepted (2026-05)

## Context

Analyze latency disputes required **evidence**, not log grep. Next.js and Python run in different processes.

## Decision

Adopt **OpenTelemetry** with OTLP HTTP to a local collector (**4318**), Jaeger for trace UI (**16686**). Instrument Next.js via `instrumentation.ts` and Python via `otel_trace.py` + kernel spans.

## Consequences

**Positive**

- End-to-end traces across Node and Python (with trace propagation).
- Load tests correlatable to span waterfalls.

**Negative**

- Operational overhead (observe compose, env vars).
- Learning curve for Jaeger Operations vs spans.

## Alternatives

- Logs only — insufficient for subprocess blind spot.
- Langfuse only — complementary; OTel chosen for request-path latency.

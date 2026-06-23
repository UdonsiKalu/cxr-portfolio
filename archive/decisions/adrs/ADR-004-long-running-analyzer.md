# ADR-004: Long-running analyzer service (:8766)

## Status

Accepted (2026-06)

## Context

`POST /api/claim-studio/analyze` spawned a **new Python subprocess** per request. Locust p95 ~**10–12s**. Jaeger showed **~7–8s** import/initialize before useful kernel spans.

## Decision

Run a **long-lived FastAPI** analyzer (`analyzer_service_app.py`) on **8766**. Next.js uses `ANALYZER_URL` and propagates trace context. Kernel + corrector warmed at startup via `get_or_create_corrector()`.

## Consequences

**Positive**

- Locust p95 **~1.5s**; Jaeger linked traces **~154–708ms** vs ~11s subprocess path.
- Clear `analyzer_service.startup` trace for import budget.
- Single place to attach Python OTel spans.

**Negative**

- Another process to run in dev (`cxr up` mitigates).
- Stale code until analyzer restart after Python changes.
- Port **8766** must be free (see [archive/demo/RUN.md](../../demo/RUN.md)).

## Alternatives considered

- Optimize kernel only — insufficient while subprocess remained.
- Minimal Jaeger profile — rejected; see [trace profiles](../../../investigations/README.md#trace-profiles).

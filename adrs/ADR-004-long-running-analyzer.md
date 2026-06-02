# ADR-004: Long-running analyzer service (:8766)

## Status

Accepted (2026-06)

## Context

`POST /api/claim-studio/analyze` spawned a **new Python subprocess** per request. Locust p95 ~**10–12s**. Jaeger showed **~7–8s** import/initialize before useful kernel spans.

## Decision

Run a **long-lived FastAPI** analyzer (`analyzer_service_app.py`) on **8766**. Next.js uses `ANALYZER_URL` and propagates trace context. Kernel + corrector warmed at startup via `get_or_create_corrector()`.

## Consequences

**Positive**

- Warm POST **~1.6–3s** vs ~11s subprocess path.
- Clear `analyzer_service.startup` trace for import budget.
- Single place to attach Python OTel spans.

**Negative**

- Another process to run in dev (`cxr up` mitigates).
- Stale code until analyzer restart after Python changes.
- Port **8766** must be free (documented in ops runbooks).

## Alternatives considered

- Optimize kernel only — insufficient while subprocess remained.
- Minimal Jaeger profile — rejected (INC-002).

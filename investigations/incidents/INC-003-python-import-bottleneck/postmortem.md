# INC-003 — Python import / init bottleneck

**Severity:** High (dev experience + load test)  
**Status:** Resolved  
**Component:** Claim Studio analyze path

## Summary

Locust and users saw **~10–12s** analyze latency. Kernel profiling showed **~1.5s** of useful work. Jaeger and timing breakdown proved **~7–8s** spent in subprocess imports and `corrector.initialize` on every request.

## Root cause

Per-request **Python subprocess** re-imported heavy deps (torch, sentence_transformers) and constructed a new `ClaimCorrectorV31Integrated()` / `CXRKernelV4Final()` each time.

## Resolution

- Deployed **FastAPI analyzer** on port **8766** with startup warm-up.
- Next.js `ANALYZER_URL` + W3C trace propagation.
- Documented `analyzer_service.startup` (~7–8s once) vs warm requests (Locust p95 ~1.5s; Jaeger traces ~154–708ms).

## Verification

- Locust p95 **~1.5s**; Jaeger linked traces **~154–708ms** on steady-state POST; `analyzer_mode: http`.
- Jaeger **~21 spans** on steady-state POST.
- [ADR-004](../../architecture/adrs/ADR-004-long-running-analyzer.md)
- [Latency investigation](../../latency-investigation/latency-investigation.md)

## Prevention

- Default dev stack via `cxr up` uses warm path.
- ADR required for re-introducing per-request subprocess in hot path.

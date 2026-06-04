# INC-001 — High API latency under load

**Severity:** High  
**Status:** Resolved (via INC-003 / ADR-004)  
**Component:** `POST /api/claim-studio/analyze`

## Summary

Under Locust, analyze API p95 **~10–12s**. Users reported Claim Studio felt unusable during load tests.

## Root cause

Same as [python-import-bottleneck](./python-import-bottleneck.md): subprocess-per-request + kernel initialization dominated; not network or Next.js alone.

## Resolution

Warm analyzer service; re-run Locust; confirm p95 **~1.5s** and Jaeger traces **~154–708ms** locally.

## Evidence

- [latency investigation](../latency-investigation/)
- Screenshots: [../latency-investigation/screenshots/](../latency-investigation/screenshots/)

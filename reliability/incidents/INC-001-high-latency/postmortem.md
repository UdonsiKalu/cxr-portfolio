# INC-001 — High API latency under load

**Severity:** High  
**Status:** Resolved (via INC-003 / ADR-004)  
**Component:** `POST /api/claim-studio/analyze`

## Summary

Under Locust, analyze API p95 **~10–12s**. Users reported Claim Studio felt unusable during load tests.

## Root cause

Same as [INC-003](../INC-003-python-import-bottleneck/postmortem.md): subprocess-per-request + kernel initialization dominated; not network or Next.js alone.

## Resolution

Warm analyzer service; re-run Locust; confirm p95 drop to **~2–3s** range locally.

## Evidence

- [latency-investigation.md](../../observability/latency-investigation.md)
- Jaeger screenshots in [observability/screenshots/](../../observability/screenshots/)

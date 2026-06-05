# Screenshots

Evidence from 2026-06-04 (`cxr down && cxr up`, then Locust 1 user on `:8251`).

| File | Source |
|------|--------|
| `jaeger-startup-7.24s.png` | Jaeger — `cxr-analyzer-service` → `analyzer_service.startup` |
| `jaeger-analyze-request-1.58s.png` | Jaeger — `analyzer_service.analyze_request` (E2E via `:8251`) |
| `locust-1user-warm.png` | Locust — 1 user, response times chart |

Original captures were side-by-side Jaeger + Locust composites; left/right halves were split for the report.

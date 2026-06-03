# Performance investigation — claim analysis latency (Locust and Jaeger)

## Symptom

Locust reported **~10–12s** p95 for `POST /api/claim-studio/analyze` while developers observed kernel stages around **~1.5s** in logs.

## Method

1. Run Locust against `http://127.0.0.1:8251` with realistic think times.
2. Export traces with OpenTelemetry (`OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318`).
3. Compare **outer** HTTP span duration vs **inner** `claim_analysis` / `context_builder` spans.
4. Repeat after architectural change (warm analyzer on **8766**).

**Two metrics, two lenses:** Locust reports aggregate client-side latency (median/p95 under load). Jaeger reports duration for **individual linked traces**. A single warm trace at ~154ms is not the same measurement as Locust p95 (~1.5s after the fix).

## Findings

### Subprocess era

| Layer | Typical duration | Visible in Jaeger? | Notes |
|-------|------------------|-------------------|-------|
| Node `executing api route` | ~10–11s | Yes | Outer HTTP span (Locust-aligned) |
| `python.module_import` | ~7–8s | Yes (after Python OTel added) | Dominant cold-path cost |
| `corrector.initialize` (SQL + embed + Qdrant) | Nested in init | Yes | Runs during kernel construction; **overlaps** import/startup — not additive on top of the ~7–8s import line |
| `context_builder` inside kernel | ~1.5s | Yes | Analyze work once runtime is loaded |
| `llm_inference` when Compliant | ~µs (skipped) | Yes | **Not** model time |

**Root cause:** per-request **new Python process** re-paid imports and kernel construction.

### Warm analyzer era

| Layer | Typical duration | Notes |
|-------|------------------|-------|
| Jaeger linked request trace | ~154–708ms observed | Warm service path |
| Locust p95 | ~1.5s observed | Client/load-test perspective |
| `analyzer_service.analyze_request` | Similar to linked request trace | Main warm request span |
| `analyzer_service.startup` | ~7–8s once per boot | Separate startup trace, not per request |

## Conclusion

The dominant source of latency was the request execution model, not the claim-analysis kernel itself.

In the original design, each request launched a new Python process and repeatedly paid startup, import, and initialization costs. OpenTelemetry spans showed that Python module imports alone consumed approximately 7–8 seconds on the slow path.

Moving the analyzer into a long-running service shifted this cost to service startup and removed it from the per-request path. This changed the performance profile from repeated cold-start latency to a warm-service request model.

## Artifacts

### Before / after (from `~/Pictures/Screenshots`)

| Phase | Screenshot |
|-------|------------|
| **Before** — Jaeger search (~11s POST) | [before-jaeger-search-2026-05-30.png](./screenshots/before-jaeger-search-2026-05-30.png) |
| **Before** — 11s waterfall, 5 spans | [before-jaeger-waterfall-11s-5spans-2026-05-30.png](./screenshots/before-jaeger-waterfall-11s-5spans-2026-05-30.png) |
| **Before** — Locust POST median 11s | [../load-testing/screenshots/before-locust-post-analyze-11s-p95-2026-06-01.png](../load-testing/screenshots/before-locust-post-analyze-11s-p95-2026-06-01.png) |
| **Before** — Jaeger + Locust combined ~10s | [before-jaeger-locust-combined-10s-2026-06-01.png](./screenshots/before-jaeger-locust-combined-10s-2026-06-01.png) |
| **Before** — `python.module_import` ~7.7s | [before-jaeger-python-module-import-7s-2026-06-01.png](./screenshots/before-jaeger-python-module-import-7s-2026-06-01.png) |
| **After** — warm analyzer ~154ms, 22 spans | [after-jaeger-locust-154ms-22spans-2026-06-02.png](./screenshots/after-jaeger-locust-154ms-22spans-2026-06-02.png) |
| **After** — warm path ~708ms | [after-jaeger-locust-warm-708ms-2026-06-02.png](./screenshots/after-jaeger-locust-warm-708ms-2026-06-02.png) |
| **After** — startup imports once (~8s) | [after-analyzer-startup-imports-8s-2026-06-02.png](./screenshots/after-analyzer-startup-imports-8s-2026-06-02.png) |

Full index: [screenshots/README.md](./screenshots/README.md)

Related load-test stats: [../load-testing/load-testing-results.md](../load-testing/load-testing-results.md)

- Decision record: [ADR-004](../../architecture/adrs/ADR-004-long-running-analyzer.md)
- Incident write-up: [INC-003](../incidents/INC-003-python-import-bottleneck/postmortem.md)

## Trace profile note

A **`minimal`** trace profile was tried to reduce Jaeger “Operations” clutter; it **reduced** useful span detail (~7 spans vs ~21). Default restored to **`detailed`**. See [INC-002](../incidents/INC-002-jaeger-trace-ux/postmortem.md).

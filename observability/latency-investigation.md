# Latency investigation — Locust vs Jaeger

## Symptom

Locust reported **~10–12s** p95 for `POST /api/claim-studio/analyze` while developers observed kernel stages around **~1.5s** in logs.

## Method

1. Run Locust against `http://127.0.0.1:8251` with realistic think times.
2. Export traces with OpenTelemetry (`OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318`).
3. Compare **outer** HTTP span duration vs **inner** `claim_analysis` / `context_builder` spans.
4. Repeat after architectural change (warm analyzer on **8766**).

## Findings

### Subprocess era

| Layer | Typical duration | Visible in Jaeger? |
|-------|------------------|-------------------|
| Node `executing api route` | ~10–11s | Yes |
| Python subprocess cold start + imports | ~7–8s | Partially (after Python OTel added) |
| `corrector.initialize` / SQL + embed + Qdrant | ~6–9s | Yes (under analyzer or subprocess) |
| `context_builder` inside kernel | ~1.5s | Yes |
| `llm_inference` when Compliant | ~µs (skipped) | Yes — **not** model time |

**Root cause:** per-request **new Python process** re-paid imports and kernel construction.

### Warm analyzer era

| Layer | Typical duration |
|-------|------------------|
| `POST /api/claim-studio/analyze` (linked trace) | **~1.6–3s** |
| `analyzer_service.analyze_request` | similar |
| `analyzer_service.startup` (once per boot) | **~7s** — separate trace |

## Conclusion

Load-test slowness was dominated by **process architecture**, not by a single slow kernel function. Optimizing `context_builder` alone would not fix Locust p95 while still spawning subprocesses.

## Artifacts

- Screenshots: [screenshots/SW11-jaeger-waterfall-post-analyze-2026-05-30.png](./screenshots/SW11-jaeger-waterfall-post-analyze-2026-05-30.png)
- Decision record: [ADR-004](../adrs/ADR-004-long-running-analyzer.md)
- Incident write-up: [INC-003](../reliability/incidents/INC-003-python-import-bottleneck/postmortem.md)

## Trace profile note

A **`minimal`** trace profile was tried to reduce Jaeger “Operations” clutter; it **reduced** useful span detail (~7 spans vs ~21). Default restored to **`detailed`**. See [INC-002](../reliability/incidents/INC-002-jaeger-trace-ux/postmortem.md).

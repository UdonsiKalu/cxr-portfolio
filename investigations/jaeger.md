# Jaeger — how to read CXR traces

## Open

http://127.0.0.1:16686

## Services

| Service | When to use |
|---------|-------------|
| `cxr-ui-rehearsal` | Full request from browser/Locust through Next.js |
| `cxr-analyzer-service` | Python-only view (startup + analyze) |

## Operations (steady-state warm POST)

Linked traces on the warm path were **~154–708ms** in local dev; Locust p95 was **~1.5s** under load. Do not conflate a single Jaeger trace with aggregate load-test latency — see [latency investigation](./latency-investigation/latency-investigation.md).

| Operation | Meaning |
|-----------|---------|
| `POST /api/claim-studio/analyze` | Outer HTTP handler |
| `analyzer_service.analyze_request` | One analyze call on :8766 |
| `context_builder` | Main kernel time (~1–2s) when warm |
| `claim_analysis` | Kernel parent span |
| `retrieval`, `evidence_fusion`, `llm_inference` | Pipeline stages |

## Operations (once per analyzer boot)

| Operation | Meaning |
|-----------|---------|
| `analyzer_service.startup` | ~7–8s import + warm corrector |
| `python.import.torch`, etc. | Per heavy dependency |

**Tip:** Restart analyzer (`cxr down` / `cxr up`) then search `analyzer_service.startup` with lookback **Last 1 hour**.

## Screenshots in this repo

- [before-jaeger-search-2026-05-30.png](./latency-investigation/screenshots/before-jaeger-search-2026-05-30.png)
- [before-jaeger-waterfall-11s-5spans-2026-05-30.png](./latency-investigation/screenshots/before-jaeger-waterfall-11s-5spans-2026-05-30.png)
- [after-jaeger-locust-154ms-22spans-2026-06-02.png](./latency-investigation/screenshots/after-jaeger-locust-154ms-22spans-2026-06-02.png)

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Only viewing GET `/claim-studio` | Filter **POST** analyze |
| Expecting ~8s on every POST when warm | Look at **startup** trace on `cxr-analyzer-service` |
| `llm_inference` ~µs | Compliant path skips LLM — check `llm.model_request.send` when LLM runs |

## Trace profiles

An attempt to simplify Jaeger via **`CXR_TRACE_PROFILE=minimal`** made investigation **harder**: **47** Operations on some services, only **~7 spans** per trace, and lost visibility into `context_builder` and imports.

**Resolution:** default restored to **`detailed`**. Added `flush_tracing()` after analyzer lifespan so **`analyzer_service.startup`** appears after restart.

**Lesson:** fewer span names ≠ clearer observability.

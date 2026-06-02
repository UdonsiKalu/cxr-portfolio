# Jaeger — how to read CXR traces

## Open

http://127.0.0.1:16686

## Services

| Service | When to use |
|---------|-------------|
| `cxr-ui-rehearsal` | Full request from browser/Locust through Next.js |
| `cxr-analyzer-service` | Python-only view (startup + analyze) |

## Operations (steady-state warm POST)

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
| `analyzer_service.startup` | ~7s import + warm corrector |
| `python.import.torch`, etc. | Per heavy dependency |

**Tip:** Restart analyzer (`cxr down` / `cxr up`) then search `analyzer_service.startup` with lookback **Last 1 hour**.

## Screenshots in this repo

- [SW11-jaeger-search-2026-05-30.png](./screenshots/SW11-jaeger-search-2026-05-30.png)
- [SW11-jaeger-waterfall-post-analyze-2026-05-30.png](./screenshots/SW11-jaeger-waterfall-post-analyze-2026-05-30.png)

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Only viewing GET `/claim-studio` | Filter **POST** analyze |
| Expecting ~8s on every POST when warm | Look at **startup** trace on `cxr-analyzer-service` |
| `llm_inference` ~µs | Compliant path skips LLM — check `llm.model_request.send` when LLM runs |

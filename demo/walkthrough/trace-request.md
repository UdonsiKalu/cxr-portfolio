# Walkthrough — trace a request in Jaeger

1. Ensure stack is up: `cxr status` → all green.
2. Open Claim Studio → **Run Analysis** once.
3. Open http://127.0.0.1:16686
4. **Search** → Service `cxr-ui-rehearsal` (or `cxr-analyzer-service`)
5. Operation `POST /api/claim-studio/analyze` · Lookback **Last 15 minutes**
6. Open a **~154–708ms** warm trace — expand:
   - `fetch POST http://127.0.0.1:8766/analyze`
   - `claim_analysis` → `context_builder`
7. Restart analyzer (`cxr down` + `cxr up`) and find **`analyzer_service.startup`** (~7s) on `cxr-analyzer-service`.

Compare to the [latency investigation report](../investigations/latency-investigation/).

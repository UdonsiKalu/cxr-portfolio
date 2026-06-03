# Walkthrough — investigate latency

1. Run Locust at http://127.0.0.1:8089 (swarm :8251)
2. Open Jaeger http://127.0.0.1:16686
3. Service `cxr-ui-rehearsal` → `POST /api/claim-studio/analyze`
4. Compare `analyzer_service.startup` (once) vs `context_builder` (steady)

Full write-up: [latency investigation report](../../investigations/latency-investigation/).

# Dependency map (local dev stack)

| Dependency | Port | Required for analyze? | Notes |
|------------|------|------------------------|-------|
| Next.js Claim Studio | 8251 | Yes | `cxr-ui-rehearsal` / rehearsal dev |
| FastAPI analyzer | 8766 | Yes (warm path) | `cxr-analyzer-service` |
| SQL Server | 1433 | Yes | Archetypes, thresholds |
| Qdrant | 6333 | Optional | WARN if down; retrieval features |
| Ollama / LLM | varies | Optional | Policy recommendation |
| OTel Collector | 4318 | For traces | OTLP HTTP |
| Jaeger UI | 16686 | For traces | Search + waterfall |
| Prometheus | 9090 | Bootcamp metrics | Observe compose |
| Grafana | 3001 | Bootcamp dashboards | Observe compose |
| Locust | 8089 | Load tests only | Targets :8251 |

Companion repos: `cxr-ui-rehearsal`, `cxr-ops-lab`, `claim_analysis_tools`.

# Service health

| Service | Check |
|---------|--------|
| Claim Studio | http://127.0.0.1:8251/claim-studio |
| Analyzer | `curl http://127.0.0.1:8766/health` |
| Jaeger | http://127.0.0.1:16686 |
| OTLP | http://127.0.0.1:4318 (collector) |

`~/staging/cxr-dev.sh status` aggregates process state.

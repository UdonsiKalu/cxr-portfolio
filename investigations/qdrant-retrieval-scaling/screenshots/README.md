# Screenshots — PERF-003 Qdrant retrieval scaling

| File | What it shows |
|------|----------------|
| [results-table-retrieval-scaling.png](results-table-retrieval-scaling.png) | Light Analyze concurrency 1→8 summary table |
| [jaeger-pressure-run-waterfall.png](jaeger-pressure-run-waterfall.png) | Full `qdrant.pressure.run` (4 tiers, 261 spans) |
| [jaeger-pressure-run-tags.png](jaeger-pressure-run-tags.png) | Root tags: tiers 8,16,32,64 |
| [jaeger-tier-concurrency-8.png](jaeger-tier-concurrency-8.png) | Tier c=8: p50/p95/RPS |
| [jaeger-tier-concurrency-16.png](jaeger-tier-concurrency-16.png) | Tier c=16 |
| [jaeger-tier-concurrency-32.png](jaeger-tier-concurrency-32.png) | Tier c=32 |
| [jaeger-tier-concurrency-64.png](jaeger-tier-concurrency-64.png) | Tier c=64 |
| [jaeger-analyzer-retrieval-76ms.png](jaeger-analyzer-retrieval-76ms.png) | Analyzer `retrieval` ~76 ms / 5 chunks |

Plain English report: [../RESULTS.md](../RESULTS.md)

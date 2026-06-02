# SLOs and SLIs (local dev)

| SLI | Target (dev) | How measured |
|-----|--------------|--------------|
| Warm analyze latency | p95 < 5s | Locust + Jaeger |
| Trace completeness | ~21 spans on steady POST | Jaeger waterfall |
| Analyzer availability | `/health` warmed | curl :8766 |

Formal production SLOs are **not** claimed in this portfolio; document here when bootcamp SLO lab is evidenced.

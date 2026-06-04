# Investigation roadmap

<!-- portfolio -->

Run Phase 1 on the local stack (`cxr-dev.sh up`, Locust `:8089`, Jaeger `:16686`).

## Story

Fixed latency → quantify cold vs warm → find capacity and saturation → kill analyzer under load → test Qdrant failure → validate traces → document one-command bootstrap.

## Order

| Step | Investigation | Folder | Status |
|------|---------------|--------|--------|
| — | Claim analysis latency | [latency-investigation/](./latency-investigation/) | ✅ |
| — | Locust baseline | [load-testing/](./load-testing/) | ✅ |
| — | Missing spans / trace profile | [missing-spans/](./missing-spans/) | ✅ |
| — | Postmortems | [postmortems/](./postmortems/) | ✅ |
| 1 | Cold vs warm analyzer | [cold-vs-warm-analyzer/](./cold-vs-warm-analyzer/) | 🔜 Next |
| 2 | Single analyzer capacity | [single-analyzer-capacity/](./single-analyzer-capacity/) | Planned |
| 3 | Analyzer saturation | [analyzer-saturation/](./analyzer-saturation/) | Planned |
| 4 | Kill analyzer under traffic | [kill-analyzer-under-traffic/](./kill-analyzer-under-traffic/) | Planned |
| 5 | Qdrant outage | [qdrant-outage/](./qdrant-outage/) | Planned |
| 6 | Trace propagation | [trace-propagation/](./trace-propagation/) | Planned |
| 7 | Platform bootstrap | [planned/platform-bootstrap.md](./planned/platform-bootstrap.md) | Planned |

> Locust p95 ≠ Jaeger single-trace duration — report both.

Backlog: [planned/](./planned/)

Index + concepts: [README.md](./README.md)

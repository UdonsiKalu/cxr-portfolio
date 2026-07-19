# Investigations

<!-- portfolio -->

Hypothesis-driven lab work on the local CXR stack (synthetic data only).

**Studies index:** [../studies/README.md](../studies/README.md)  
**Archived folders:** [ARCHIVED.md](./ARCHIVED.md) · [../archive/old-investigations/](../archive/old-investigations/)

**New study:** copy [template-investigation.md](./template-investigation.md) → `<id>/README.md`

---

## Active

| Investigation | Entry |
|---------------|--------|
| Claim analysis latency | [latency-investigation/](./latency-investigation/) |
| Locust load program | [load-testing/](./load-testing/) |
| Cold vs warm analyzer | [cold-vs-warm-analyzer/](./cold-vs-warm-analyzer/) |
| Bootcamp CI pipeline | [ci-pipeline/](./ci-pipeline/) |
| Kubernetes saturation (LOAD-003+) | [kubernetes-analyzer-saturation/](./kubernetes-analyzer-saturation/) |
| Ollama outage (REL-002) | [ollama-outage/](./ollama-outage/) |
| Database unavailable (REL-004) | [database-unavailable/](./database-unavailable/) |
| Qdrant retrieval scaling (PERF-003 / #7) | [qdrant-retrieval-scaling/](./qdrant-retrieval-scaling/) |
| Alerting strategy (OBS-003 / #19) | [alerting-strategy/](./alerting-strategy/) |
| CPU starvation (CHAOS-004 / #17) | [cpu-starvation/](./cpu-starvation/) |
| Game day (combined failures / #18) | [game-day/](./game-day/) |
| Network latency (CHAOS-002 / #15) | [network-latency-injection/](./network-latency-injection/) |
| Packet loss (CHAOS-003 / #16) | [packet-loss-injection/](./packet-loss-injection/) |
| Planned backlog | [planned/](./planned/) |

---

## Notes

- Prefer **Markdown on GitHub** for write-ups. Optional Jupyter notebooks under a study folder are fine but not required.
- Locust p95 (aggregate) ≠ Jaeger single-trace duration — report both when relevant.
- Changelog: [../CHANGELOG.md](../CHANGELOG.md)

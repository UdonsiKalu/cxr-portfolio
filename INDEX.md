# Portfolio index

**Maturity legend:** Complete · MVP · Scaffold · Reference

| Path | Status | Notes |
|------|--------|-------|
| [README.md](./README.md) | Complete | Entry + 10-minute path |
| [STRUCTURE.md](./STRUCTURE.md) | Complete | Full tree map |
| [my-impact.md](./my-impact.md) | Complete | Outcomes summary |
| [DISCLAIMER.md](./DISCLAIMER.md) | Complete | Synthetic data / labs |
| **architecture/** | MVP | C4 markdown; [diagrams/](./architecture/diagrams/) PNGs planned |
| **platform-thinking/** | MVP | Philosophy complete; journey + model scaffold |
| **observability/** | Complete (core) | Latency, Jaeger, screenshots; Prom/Grafana scaffold |
| **reliability/incidents/** | Complete (3) | INC-001/003 + **INC-002-jaeger-trace-ux** |
| **reliability/chaos-experiments/** | Scaffold | No game-day evidence yet |
| **reliability/runbooks/** | MVP | slow-api, no-traces, restart-stack |
| **operations/** | MVP | docker, ci-cd, restart; K8/tf **reference** copies |
| **security-compliance/** | Scaffold | Outline only |
| **adrs/** | MVP | ADR-001–004 complete; 005–006 scaffold |
| **demo/** | MVP | [RUN.md](./demo/RUN.md); compose single-clone planned |
| **archive/** | Optional | bootcamp index under learning-notes |
| **templates/** | Complete | Postmortem + ADR + extra templates |

## Reviewer fast path (implemented today)

1. [my-impact.md](./my-impact.md)
2. [observability/latency-investigation.md](./observability/latency-investigation.md)
3. [reliability/incidents/INC-003-python-import-bottleneck/postmortem.md](./reliability/incidents/INC-003-python-import-bottleneck/postmortem.md)
4. [observability/screenshots/](./observability/screenshots/)
5. [demo/RUN.md](./demo/RUN.md)

## Phase 2 (fill scaffolds with evidence)

- Architecture PNGs in `architecture/diagrams/`
- Chaos / SLO / DR sections
- `demo/docker-compose.yml` single-clone reviewer stack
- ADR-005/006 when K8 split is committed

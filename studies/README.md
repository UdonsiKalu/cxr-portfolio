# Studies index

<!-- portfolio -->

One place to find **investigation write-ups**. Docs still live next to their evidence (no mass move in this phase).

## LOAD-003 / Kubernetes saturation arc

Full table: [kubernetes-analyzer-saturation/studies/](investigations/kubernetes-analyzer-saturation/studies/README.md)

| ID | Study |
|----|--------|
| OBS-001 | [load-observe RUN-2026-06-17](investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) |
| PERF-002 | [Context builder bottleneck](investigations/kubernetes-analyzer-saturation/studies/PERF-002-context-builder-bottleneck.md) |
| GATE-002 | [KEDA Helm grid](investigations/kubernetes-analyzer-saturation/studies/GATE-002-keda-helm-grid-study.md) |
| PERF-008 | [Queue-depth autoscaling](investigations/kubernetes-analyzer-saturation/studies/PERF-008-queue-depth-autoscaling.md) |
| PERF-009 | [Jaeger tail latency](investigations/kubernetes-analyzer-saturation/studies/PERF-009-jaeger-tail-latency.md) |
| OBS-003 | [Shared SQL / context errors under load](investigations/kubernetes-analyzer-saturation/studies/OBS-003-shared-sql-connection.md) |
| SCALE-003 | [UI bottleneck at peak load](investigations/kubernetes-analyzer-saturation/studies/SCALE-003-ui-bottleneck.md) |
| REL-002 | [Ollama outage](investigations/ollama-outage/) |

## Earlier arcs (folder READMEs)

| Theme | Entry |
|-------|--------|
| Subprocess → warm analyzer | [latency-investigation](investigations/latency-investigation/) |
| Locust load program (baseline → LOAD-001/002) | [load-testing](investigations/load-testing/) · [archives](archive/old-investigations/) |
| Cold vs warm | [cold-vs-warm-analyzer](investigations/cold-vs-warm-analyzer/) |
| CI evidence | [ci-pipeline](investigations/ci-pipeline/) |

## Archived investigations

Completed LOAD-001/002, chaos, deploy, etc. live under [archive/old-investigations/](archive/old-investigations/README.md). Path map: [investigations/ARCHIVED.md](investigations/ARCHIVED.md).

## Open backlog

Planned specs (not yet promoted): [investigations/planned/](investigations/planned/README.md) · GitHub milestone **Phase 2 — investigations backlog**.

## Narrative

Challenges rollup: [failures/README.md](failures/README.md) · dated log: [CHANGELOG.md](CHANGELOG.md).

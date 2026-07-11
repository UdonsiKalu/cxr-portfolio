# LOAD-003 studies (write-ups + evidence)

**One folder per investigation arc** — study docs live here beside `evidence/` and `results/`.

Portfolio-wide index: [studies/README.md](../../../studies/README.md).

| Study | Doc | Evidence |
|-------|-----|----------|
| OBS-001 | — | [evidence/load-observe/RUN-2026-06-17.md](../evidence/load-observe/RUN-2026-06-17.md) |
| PERF-002 | [PERF-002-context-builder-bottleneck.md](PERF-002-context-builder-bottleneck.md) | [load-observe](../evidence/load-observe/) · CHANGELOG PERF-003 verify |
| GATE-002 | [GATE-002-keda-helm-grid-study.md](GATE-002-keda-helm-grid-study.md) | [results/tuner/](../results/tuner/) · [grafana-arcs](../evidence/grafana-arcs/) |
| PERF-008 | [PERF-008-queue-depth-autoscaling.md](PERF-008-queue-depth-autoscaling.md) | [evidence/perf008/](../evidence/perf008/) |
| PERF-009 | [PERF-009-jaeger-tail-latency.md](PERF-009-jaeger-tail-latency.md) | [evidence/perf009/](../evidence/perf009/) |
| OBS-003 | [OBS-003-shared-sql-connection.md](OBS-003-shared-sql-connection.md) — SQL context errors under load | [evidence/obs003/](../evidence/obs003/) · [issue #33](https://github.com/UdonsiKalu/cxr-portfolio/issues/33) (closed) · [cxr-platform PR #8](https://github.com/UdonsiKalu/cxr-platform/pull/8) (merged) |
| GIT-001 | GATE-002 caps in Git Helm values (UI max 4) | [GATE-002](GATE-002-keda-helm-grid-study.md) · [failures Arc 7](../../../failures/README.md#arc-7--git-and-the-cluster-disagreed-git-001) · [issue #24](https://github.com/UdonsiKalu/cxr-portfolio/issues/24) (closed) · [cxr-platform PR #11](https://github.com/UdonsiKalu/cxr-platform/pull/11) |
| SCALE-003 | [SCALE-003-ui-bottleneck.md](SCALE-003-ui-bottleneck.md) — UI path bottleneck at peak load | [evidence/scale003/](../evidence/scale003/) · [issue #23](https://github.com/UdonsiKalu/cxr-portfolio/issues/23) |

**When you close a study:** update the study `.md`, `evidence/`, and one [CHANGELOG.md](../../../CHANGELOG.md) entry. [failures/README.md](../../../failures/README.md) only on major arc milestones.

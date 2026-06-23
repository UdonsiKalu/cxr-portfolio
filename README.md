# CXR — DevOps Portfolio

<!-- portfolio -->

**CXR** (Claim eXamination & Reasoning) — healthcare claims analysis used as the subject of **platform engineering, DevOps, and SRE-style** lab work. Synthetic data only; not production.

---

## DevOps workflow (maintainers)

| When you close a study | Update |
|------------------------|--------|
| **Required** | Study write-up under `investigations/<name>/studies/` · `evidence/` · [CHANGELOG.md](CHANGELOG.md) |
| **Milestone only** | [failures/README.md](failures/README.md) arc summary |
| **Rarely** | [architecture/adrs/](architecture/adrs/) · [reliability/SLO.md](reliability/SLO.md) |

**GitHub:** [operations/GITHUB-WORKFLOW.md](operations/GITHUB-WORKFLOW.md) — Issues, PRs, Kanban.

**LOAD-003 arc (current):** [kubernetes-analyzer-saturation/studies/](investigations/kubernetes-analyzer-saturation/studies/) — GATE-002, PERF-008, PERF-009 beside evidence.

---

## Repository layout

| Path | Role |
|------|------|
| [investigations/](investigations/README.md) | Hypothesis, method, **studies**, evidence |
| [operations/](operations/README.md) | CI/CD, stack ops, **GitHub workflow** |
| [CHANGELOG.md](CHANGELOG.md) | Dated audit log (one entry per landed study) |
| [failures/](failures/README.md) | Honest index of rejected paths (arc rollups) |
| [reliability/SLO.md](reliability/SLO.md) | SLIs and load gates |
| [architecture/adrs/](architecture/README.md) | Stable decision records |
| [archive/](archive/README.md) | Reviewer pack, demo walkthroughs, C4 diagrams |

---

## Featured arcs

### Latency — subprocess → warm analyzer

~10–12s analyze under load → Jaeger showed Python import per request → long-running analyzer on **:8766** → p95 ~1.5s.

- [latency investigation](investigations/latency-investigation/) · [postmortem](investigations/postmortems/python-import-bottleneck.md) · [ADR-004](architecture/adrs/ADR-004-long-running-analyzer.md)

### Capacity — K8 saturation, GATE-002, PERF-008/009

- [LOAD-003](investigations/kubernetes-analyzer-saturation/) · [OBS-001](investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md)
- [GATE-002](investigations/kubernetes-analyzer-saturation/studies/GATE-002-keda-helm-grid-study.md) · [PERF-008](investigations/kubernetes-analyzer-saturation/studies/PERF-008-queue-depth-autoscaling.md) · [PERF-009](investigations/kubernetes-analyzer-saturation/studies/PERF-009-jaeger-tail-latency.md)

---

## For reviewers (optional path)

Academic / hiring review: [archive/reviewer/REVIEWER-GUIDE.md](archive/reviewer/REVIEWER-GUIDE.md) · [history](archive/reviewer/history.md) · [impact summary](archive/meta/my-impact.md).

Hands-on lab: `cxr-ops-lab` + [archive/demo/RUN.md](archive/demo/RUN.md).

---

## Companion repos

`cxr-ops-lab` (deploy/gates) · `cxr-ui-rehearsal` (UI) · `cxrlabs-dev/claim_analysis_tools` (analyzer)

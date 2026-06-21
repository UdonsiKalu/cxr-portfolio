# Investigations index

Each folder under [`investigations/`](../investigations/) is one **question** run against the local CXR stack: hypothesis, method, evidence, outcome.

**Synthetic data · dev environment only.** Full lab index: [investigations/README.md](../investigations/README.md).

---

## Completed studies (evidence-backed)

| ID | Folder | Question (short) | Status |
|----|--------|------------------|--------|
| LAT | [latency-investigation](../investigations/latency-investigation/) | Why is analyze ~10s under load? | Complete |
| LOAD-001 | [single-analyzer-capacity](../investigations/single-analyzer-capacity/) | Capacity of one warm analyzer | Complete |
| LOAD-002 | [analyzer-saturation](../investigations/analyzer-saturation/) | Single-process saturation knee | Complete |
| LOAD-003 | [kubernetes-analyzer-saturation](../investigations/kubernetes-analyzer-saturation/) | K8 HPA vs LOAD-002; OBS deep dive | Complete |
| GATE-002 | [tuner results](../investigations/kubernetes-analyzer-saturation/results/tuner/) | Helm grid under analyze saturation | Complete (2026-06-19) |
| OTEL-001 | [trace-propagation](../investigations/trace-propagation/) | End-to-end trace linkage | Complete |
| CI-001 | [ci-pipeline](../investigations/ci-pipeline/) | GitHub Actions validation | Complete |
| K8-001 | [kubernetes-deploy](../investigations/kubernetes-deploy/) | Helm deploy to local K8 | Complete |
| CHAOS-001 | [kill-analyzer-under-traffic](../investigations/kill-analyzer-under-traffic/) | Behavior when analyzer killed under load | Complete |
| DEP-001 | [qdrant-outage](../investigations/qdrant-outage/) | Analyzer when Qdrant unavailable | Complete |
| PERF-004 | [cold-vs-warm-analyzer](../investigations/cold-vs-warm-analyzer/) | Cold vs warm startup | Complete |
| — | [load-testing](../investigations/load-testing/) | Early Locust baseline | Complete |
| — | [missing-spans](../investigations/missing-spans/) | Trace completeness / Jaeger UX | Complete |

---

## Key evidence files (LOAD arc)

| Artifact | Link |
|----------|------|
| OBS-001 run write-up | [RUN-2026-06-17.md](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) |
| GATE-002 winner | [tuner-summary-20260619-080505.json](../investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json) |
| Failed Jun 18 ramp | [load-20260618-064836.csv](../investigations/kubernetes-analyzer-saturation/results/load-20260618-064836.csv) (if present in clone) |
| Screenshots | [kubernetes-analyzer-saturation/screenshots/](../investigations/kubernetes-analyzer-saturation/screenshots/) |

---

## Planned (not evidence — do not cite as completed)

See [investigations/planned/](../investigations/planned/) — context-builder hardening, game-day, alerting, etc.

---

## How investigations relate to other docs

| Doc type | Relationship |
|----------|----------------|
| [CHANGELOG](../CHANGELOG.md) | Dated cross-links when an investigation lands |
| [Postmortems](postmortems/README.md) | Incident-shaped spin-offs |
| [Failures](../failures/README.md) | Failed runs within or across investigations |
| [ADRs](decisions/README.md) | Decisions triggered by investigation findings |
| [SLOs](../reliability/SLO.md) | Gates and targets derived from LOAD work |

---

## Runnable scripts

Implementation lives in **`cxr-ops-lab`** (sibling repo): load gates, Helm, observe stack. This portfolio holds **reports, CSV summaries, screenshots, and JSON gate results**.

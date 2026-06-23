# Reviewer guide (academic and technical)

Use this checklist to evaluate CXR as a **complete engineering portfolio**: architecture, observability, performance, reliability, operations, and honest reporting of failures.

**Environment:** Local development lab, synthetic claims data. See [DISCLAIMER](../archive/DISCLAIMER.md).

---

## Evaluation rubric (what to look for)

| Criterion | Where to find evidence |
|-----------|------------------------|
| **Problem framing** | [my-impact.md](../archive/meta/my-impact.md), investigation READMEs (Question / Hypothesis) |
| **Methodology** | Locust load tests, Jaeger traces, K8 metrics CSV, automated gates |
| **Root-cause analysis** | Postmortems, OBS-001 run doc, latency investigation |
| **Architectural decisions** | [ADRs](../archive/decisions/adrs/) |
| **Iteration & mistakes** | [CHANGELOG](../CHANGELOG.md), [failures/](../failures/README.md) |
| **Operational practice** | [operations/](../operations/README.md), SLO doc, CI/K8 investigations |
| **Reproducibility** | Scripts in `cxr-ops-lab` (linked), demo runbook, tuner JSON summaries |
| **Scope honesty** | Disclaimers, “lab not prod”, planned vs complete labels |

---

## Section-by-section checklist

### 1. Development history

- [ ] Read [history.md](history.md) — four arcs (latency, capacity, reliability, platform)  
- [ ] Skim [CHANGELOG.md](../CHANGELOG.md) — newest entries under Investigations and Operations  
- [ ] Confirm failed paths are documented as a readable narrative ([failures/README.md](../failures/README.md))

### 2. Architecture & decisions

- [ ] [archive/decisions/README.md](../archive/decisions/README.md) — system context  
- [ ] [architecture-evolution.md](../archive/architecture-c4/architecture-evolution.md) — how design changed  
- [ ] ADRs (minimum): [ADR-004](../archive/decisions/adrs/ADR-004-long-running-analyzer.md), [ADR-002](../archive/decisions/adrs/ADR-002-opentelemetry.md), [ADR-005](../archive/decisions/adrs/ADR-005-kubernetes-roadmap.md)  
- [ ] Full index: [decisions/README.md](decisions/README.md)

### 3. Investigations (performance & observability)

| ID | Study | Key evidence |
|----|-------|--------------|
| LAT | [latency-investigation](../investigations/latency-investigation/) | Jaeger waterfalls, before/after p95 |
| LOAD-001 | [single-analyzer-capacity](../investigations/single-analyzer-capacity/) | Staged ramp screenshots |
| LOAD-002 | [analyzer-saturation](../investigations/analyzer-saturation/) | Continuous ramp to ~225 users |
| LOAD-003 | [kubernetes-analyzer-saturation](../investigations/kubernetes-analyzer-saturation/) | HPA, Grafana, OBS-001 |
| GATE-002 | [tuner summary](../investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json) | 12-candidate Helm grid, winner |
| OTEL | [trace-propagation](../investigations/trace-propagation/) | Cross-service traceparent |
| CHAOS | [kill-analyzer-under-traffic](../investigations/kill-analyzer-under-traffic/) | Failure mode under load |
| DEP | [qdrant-outage](../investigations/qdrant-outage/) | Dependency outage behavior |

Full index: [investigations/README.md](investigations/README.md)

### 4. Postmortems

- [ ] [python-import-bottleneck](../investigations/postmortems/python-import-bottleneck.md)  
- [ ] [high-latency-under-load](../investigations/postmortems/high-latency-under-load.md)  
- [ ] [jaeger-trace-profile](../investigations/postmortems/jaeger-trace-profile.md)  

Index: [postmortems/README.md](postmortems/README.md)

### 5. Reliability & SLOs

- [ ] [reliability/SLO.md](../reliability/SLO.md) — SLI/SLO tiers, gate vs production  
- [ ] Distinguish **capacity gate pass** (synthetic 200 users) from **production SLO** (proposed, not prod-measured)

### 6. Operations & platform

- [ ] [operations/ci-cd.md](../operations/ci-cd.md) — CI investigation  
- [ ] [kubernetes-deploy](../investigations/kubernetes-deploy/) — K8-001  
- [ ] [archive/demo/RUN.md](../archive/demo/RUN.md) — runnable stack (optional hands-on)

---

## Suggested interview / advisory questions

1. Why move from subprocess-per-request to a long-running analyzer? What evidence justified it?  
2. LOAD-003 showed high p95 with low node CPU — what was the actual bottleneck?  
3. What failed in GATE-002 candidate 1, and why did candidate 4 win?  
4. What would you **not** claim about production readiness based on this portfolio?  
5. How do SLOs, load gates, and the changelog relate — are they consistent?

---

## Optional hands-on reproduction

Requires local Docker/K8 setup (~1–2 hours). Not required for document-only review.

1. [archive/demo/RUN.md](../archive/demo/RUN.md) — warm stack + Jaeger  
2. `cxr-ops-lab` — `16-k8-stack-verify.sh`, `k8-load-gate.sh` (see ops-lab `docs/K8-LOAD-GATE.md` on that repo)

---

## Contact & context

This portfolio supports professional and academic review of **DevOps / platform / SRE practice** applied to a real (lab-scoped) healthcare analytics stack. For questions about scope or reproduction, refer to the changelog entry dates and linked artifacts rather than summary prose alone.

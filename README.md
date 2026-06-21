# CXR — DevOps Portfolio

<!-- portfolio -->

**CXR** (Claim eXamination & Reasoning) is a healthcare claims analysis system used as the subject of real engineering work—not a product demo repo.

This portfolio documents **platform engineering, DevOps, and SRE-style practice**: architecture, observability, reliability, performance investigations, and operations. Evidence comes from development environments with **synthetic data**, not production workloads.

---

## For reviewers and academic advisors

**Start here:** **[docs/README.md](docs/README.md)** — entry point with reading paths (15 min / 45 min / half day).

| Element | Link |
|---------|------|
| Reviewer checklist | [docs/REVIEWER-GUIDE.md](docs/REVIEWER-GUIDE.md) |
| Development history (curated) | [docs/history.md](docs/history.md) |
| Full changelog | [CHANGELOG.md](CHANGELOG.md) |
| Investigations | [docs/investigations/README.md](docs/investigations/README.md) |
| Decisions (ADRs) | [docs/decisions/README.md](docs/decisions/README.md) |
| Postmortems | [docs/postmortems/README.md](docs/postmortems/README.md) |
| Failures (honest index) | [failures/README.md](failures/README.md) |
| SLOs & reliability | [reliability/SLO.md](reliability/SLO.md) |
| Impact summary | [archive/meta/my-impact.md](archive/meta/my-impact.md) |
| Disclaimer | [archive/DISCLAIMER.md](archive/DISCLAIMER.md) |
| Going public | [docs/GO-PUBLIC.md](docs/GO-PUBLIC.md) |

---

## Purpose

This repository is an **engineering portfolio and documentation repository**. It is not the full CXR product codebase. Companion implementation repos: `cxr-ops-lab`, `cxr-ui-rehearsal`, `cxrlabs-dev/claim_analysis_tools` (linked from investigations and operations docs).

---

## Repository structure

- **[docs/](docs/README.md)** — reviewer hub (start here for external review)
- **[CHANGELOG.md](CHANGELOG.md)** — project-wide audit log
- **[architecture/](architecture/README.md)** — system design, ADRs, evolution
- **[investigations/](investigations/README.md)** — performance, load, reliability studies
- **[failures/](failures/README.md)** — failed experiments and reverted paths
- **[reliability/](reliability/SLO.md)** — SLIs, SLOs, load gates
- **[operations/](operations/README.md)** — Docker, CI/CD, Kubernetes
- **[demo/](demo/README.md)** — local demonstration walkthroughs

---

## Featured work (two arcs)

### Latency — subprocess to warm analyzer

Claim analysis averaged **~10–12s** under load. OpenTelemetry + Jaeger showed **Python import cost per request**. Migration to a long-running analyzer on **:8766** dropped Locust p95 to **~1.5s**.

- [latency investigation](investigations/latency-investigation/)
- [postmortem: python import bottleneck](investigations/postmortems/python-import-bottleneck.md)
- [ADR-004](architecture/adrs/ADR-004-long-running-analyzer.md)

### Capacity — Kubernetes saturation & GATE-002

LOAD-003 + OBS-001 showed **p95 ~9s** at 200 users with **low node CPU** (autoscaling/scheduling, not host exhaustion). Automated Helm tuner (**GATE-002**, 2026-06-19): **11/12** recipes passed; winner **~102 RPS**, **0 failures**, p95 **~820ms** @ 200 synthetic analyze users.

- [kubernetes-analyzer-saturation](investigations/kubernetes-analyzer-saturation/)
- [OBS-001 run doc](investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md)
- [GATE-002 tuner winner (JSON)](investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json)

---

## Engineering lab workspace (optional)

For hands-on reproduction: [demo/RUN.md](demo/RUN.md), [cxr-lab.code-workspace](cxr-lab.code-workspace), Jupyter notebooks under `investigations/`. Reviewers doing **document-only** review can skip this section.

---

## Navigate investigations

- Markdown index: [investigations/README.md](investigations/README.md)
- Jupyter: `investigations/README.ipynb` (local lab)

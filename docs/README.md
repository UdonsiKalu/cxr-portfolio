# CXR portfolio — reviewer entry point

**Start here** if you are an academic advisor, thesis reviewer, hiring manager, or collaborator evaluating this work.

This repository documents **platform engineering, DevOps, and SRE-style practice** on **CXR** (Claim eXamination & Reasoning) — a healthcare claims analysis system studied in **local lab environments with synthetic data**. It is **not** the CXR application codebase; it is the **evidence and narrative layer** for investigations, decisions, and operational learnings. Runnable code lives in companion repos (`cxr-ops-lab`, analyzer, UI) and is **linked**, not embedded here.

**Timeline:** Investigation folders and commits span **2025–2026** lab work. The root [CHANGELOG.md](../CHANGELOG.md) is a **consolidated audit log** (from June 2026); per-study evidence remains in each investigation folder with its own dates.

**Maintainers:** work is tracked via [GitHub Issues](https://github.com/UdonsiKalu/cxr-portfolio/issues) and [GITHUB-WORKFLOW.md](GITHUB-WORKFLOW.md) (Projects, PRs, releases).

---

## What this repo contains

| Element | Purpose | Start here |
|---------|---------|------------|
| **Development history** | Curated arc of major milestones | [history.md](history.md) |
| **Changelog** | Dated journal of problems, fixes, mistakes | [../CHANGELOG.md](../CHANGELOG.md) |
| **Investigations** | Hypothesis-driven studies with evidence | [investigations/README.md](investigations/README.md) |
| **Decisions (ADRs)** | Why the architecture looks the way it does | [decisions/README.md](decisions/README.md) |
| **Postmortems** | Incident-shaped write-ups | [postmortems/README.md](postmortems/README.md) |
| **Failures** | Experiments and paths that failed (honest index) | [../failures/README.md](../failures/README.md) |
| **Reliability / SLOs** | SLIs, gates, error-budget framing | [../reliability/SLO.md](../reliability/SLO.md) |
| **Architecture** | C4, request flow, evolution | [../architecture/README.md](../architecture/README.md) |
| **Operations** | Docker, CI/CD, Kubernetes | [../operations/README.md](../operations/README.md) |
| **Demo** | Runnable walkthrough | [../demo/RUN.md](../demo/RUN.md) |
| **GitHub workflow** | Issues, Projects, PRs, CI | [GITHUB-WORKFLOW.md](GITHUB-WORKFLOW.md) |

**Disclaimer:** [../archive/DISCLAIMER.md](../archive/DISCLAIMER.md) — synthetic data, lab-only configs, not production.

---

## Recommended reading paths

### 15 minutes — executive summary

1. [../archive/meta/my-impact.md](../archive/meta/my-impact.md) — problem, outcomes, metrics before/after  
2. [history.md](history.md) — four development arcs in one page  
3. [../architecture/adrs/ADR-004-long-running-analyzer.md](../architecture/adrs/ADR-004-long-running-analyzer.md) — flagship architectural fix  

### 45 minutes — technical review

Add to the path above:

4. [../investigations/latency-investigation/README.md](../investigations/latency-investigation/README.md) — tracing + root cause  
5. [../investigations/postmortems/python-import-bottleneck.md](../investigations/postmortems/python-import-bottleneck.md) — incident record  
6. [../investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) — OBS-001 deep dive  
7. [GATE-002-keda-helm-grid-study.md](GATE-002-keda-helm-grid-study.md) — first KEDA apply, 12-candidate Helm grid (Jun 19)  
8. [PERF-008-queue-depth-autoscaling.md](PERF-008-queue-depth-autoscaling.md) — OBS-002 fix + KEDA A/B (p95 vs inflight)  

### Half day — full project review

Follow [REVIEWER-GUIDE.md](REVIEWER-GUIDE.md) for a structured checklist across all elements.

---

## How the pieces fit together

```
CHANGELOG (when — cross-cutting journal)
    │
    ├── investigations/ (how we learned — method + evidence)
    │       └── postmortems/ (incident narrative when something broke)
    │
    ├── architecture/adrs/ (why we chose X over Y)
    │
    ├── failures/ (what we tried and rejected — links only)
    │
    └── reliability/SLO.md (what “good enough” means)
```

**Rule:** Each layer links to the others; prose is not duplicated. The changelog points to investigations; investigations point to CSVs, screenshots, and ADRs.

---

## Companion repositories

| Repo | Role |
|------|------|
| **`cxr-portfolio`** (this repo) | Documentation, evidence, ADRs, investigations |
| **`cxr-ops-lab`** | Deploy scripts, Helm, K8 load gates, observe stack |
| **`cxr-ui-rehearsal`** | Claim Studio UI (rehearsal) |
| **`cxrlabs-dev/claim_analysis_tools`** | Analyzer service |

Reviewers can evaluate the portfolio **without cloning all repos**; runnable reproduction is optional via [../demo/RUN.md](../demo/RUN.md).

---

## Maintainer notes

- Daily lab work may use Jupyter notebooks under `investigations/`; markdown in this repo is the **GitHub-rendered** source of truth.  
- [../archive/meta/PORTFOLIO-STATUS.md](../archive/meta/PORTFOLIO-STATUS.md) — go-public checklist (maintainers).  
- [GO-PUBLIC.md](GO-PUBLIC.md) — steps to publish and pin on GitHub profile.

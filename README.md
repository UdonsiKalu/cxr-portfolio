# CXR — DevOps Portfolio

<!-- portfolio -->

**CXR** (Claim eXamination & Reasoning) is a healthcare claims analysis system used as the subject of real engineering work—not a product demo repo.

This portfolio documents **platform engineering, DevOps, and SRE-style practice** on that system: architecture, observability, reliability, performance investigations, and operations. Evidence comes from development environments with synthetic data, not production workloads.

> **Progression & audit trail:** [CHANGELOG.md](CHANGELOG.md) — problems, mistakes, fixes, and decisions across investigations, architecture, operations, and platform work (for reviewers and interviewers).

> **Navigate:** open **`README.ipynb`** or start JupyterLab — see [investigations/README.ipynb](investigations/README.ipynb). Do not use `.md` for daily links in Cursor.

---

## Purpose

The goal of this repository is to document:

- System architecture and design decisions
- Performance investigations and optimization work
- Observability and tracing implementations
- Reliability and operational practices
- Platform evolution and future architecture plans

This repository is an **engineering portfolio and documentation repository**. It is not the full CXR product codebase.

---

## Repository Structure

- **[CHANGELOG.md](CHANGELOG.md)** — project-wide history (problems, decisions, progress) for reviewers
- [architecture/README.md](architecture/README.md) — system design, request flows, diagrams, [architecture evolution](architecture/architecture-evolution.md), [ADRs](architecture/adrs/ADR-004-long-running-analyzer.md)
- [investigations/README.md](investigations/README.md) — performance, load, reliability, observability investigations
- [operations/README.md](operations/README.md) — Docker, CI/CD, deployment, Kubernetes planning
- [demo/README.md](demo/README.md) — local demonstration environment and walkthroughs
- [archive/README.md](archive/README.md) — reference material and supporting notes

---

## Engineering lab workspace

This repo is the **documentation and evidence** layer. Code runs in sibling trees opened via multi-root workspace.

- [Open lab workspace](cxr-lab.code-workspace) — **File → Open Workspace from File…** (includes portfolio + ops-lab + UI)
- [investigations/README.ipynb](investigations/README.ipynb) — open in JupyterLab (not `.md`)
- [Investigation navigation](investigations/00-navigation.ipynb)
- [New investigation template](investigations/template-investigation.ipynb)
- [Script registry](scripts/README.md) — links only; scripts stay in place
- [Lab workflow diagram](architecture/diagrams/lab-workflow.mmd)

Deploy / CI runtime: `cxr-ops-lab`, `cxr-ui-rehearsal` (sibling repos on disk).

---

## Featured Investigation

One of the investigations documented here involved claim analysis requests averaging approximately **10–12 seconds** under load.

Using **OpenTelemetry**, **Jaeger**, and **Locust**, the work identified repeated Python startup and import costs as a major contributor to latency. The response was a migration from a subprocess-per-request architecture to a **long-running analyzer service** on port **8766**. After the change, Locust p95 dropped to **~1.5s** and warm Jaeger traces showed **~154–708ms** per request.

- Open **`investigations/latency-investigation/notebook.ipynb`** in JupyterLab — full report
- [Python import bottleneck](investigations/postmortems/python-import-bottleneck.md) — incident record
- [ADR-004 — long-running analyzer](architecture/adrs/ADR-004-long-running-analyzer.md) — architecture decision

Full index: **`investigations/00-navigation.ipynb`**

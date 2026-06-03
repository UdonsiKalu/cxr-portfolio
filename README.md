# CXR — DevOps Portfolio

<!-- portfolio -->

**CXR** (Claim eXamination & Reasoning) is a healthcare claims analysis system used as the subject of real engineering work—not a product demo repo.

This portfolio documents **platform engineering, DevOps, and SRE-style practice** on that system: architecture, observability, reliability, performance investigations, and operations. Evidence comes from development environments with synthetic data, not production workloads.

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

| Section | Contents |
|---------|----------|
| [architecture/](./architecture/) | System design, request flows, diagrams, [architecture evolution](./architecture/architecture-evolution.md), and [ADRs](./architecture/adrs/) |
| [investigations/](./investigations/) | Performance work, load testing, tracing, incidents, reliability experiments — see [investigations index](./investigations/README.md) |
| [operations/](./operations/) | Docker, CI/CD, deployment, Kubernetes planning, Terraform, and operational procedures |
| [demo/](./demo/) | Local demonstration environment and walkthroughs |
| [archive/](./archive/) | Reference material and supporting notes |

---

## Featured Investigation

One of the investigations documented here involved claim analysis requests averaging approximately **10–12 seconds** under load.

Using **OpenTelemetry**, **Jaeger**, and **Locust**, the work identified repeated Python startup and import costs as a major contributor to latency. The response was a migration from a subprocess-per-request architecture to a **long-running analyzer service** on port **8766**. After the change, Locust p95 dropped to **~1.5s** and warm Jaeger traces showed **~154–708ms** per request.

| Document | Description |
|----------|-------------|
| [Latency investigation](./investigations/latency-investigation/) | Full report with evidence and diagrams |
| [INC-003 — import bottleneck](./investigations/incidents/INC-003-python-import-bottleneck/) | Incident record |
| [ADR-004 — long-running analyzer](./architecture/adrs/ADR-004-long-running-analyzer.md) | Architecture decision |

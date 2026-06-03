# CXR — Claims Reasoning Platform

<!-- portfolio -->

CXR (Claim eXamination & Reasoning) is a healthcare-focused claims analysis platform designed to identify issues that may contribute to claim denials before submission.

This repository documents the engineering work performed while developing and operating CXR. The focus is on architecture, observability, reliability, performance analysis, and platform operations using a real system rather than isolated demonstrations.

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

---

## Author

**Udonsi Kalu**

Platform engineering, observability, reliability engineering, and AI systems work documented through the development and operation of CXR.

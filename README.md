# CXR — Claims Reasoning Platform (Engineering Portfolio)

This repository documents the engineering work behind CXR (Claim eXamination & Reasoning), a healthcare-focused claims analysis platform.

The portfolio focuses on architecture, observability, reliability, performance investigations, and platform operations using a real system rather than isolated demonstrations.

---

## Repository Structure

### Architecture

System design, request flows, C4 diagrams, [architecture evolution](./architecture/architecture-evolution.md), and ADRs in `adrs/`.

### Investigations

Performance investigations, incident analysis, load testing, tracing, runbooks, and reliability experiments.

### Operations

Docker, CI/CD, GitHub Actions, Kubernetes, Terraform, deployment practices, and capacity planning.

### Demo

Local demonstration environment and walkthroughs.

### Archive

Supporting notes, templates, and reference material.

---

## Recommended Review Path

1. `my-impact.md`
2. `architecture/request-flow.md`
3. `investigations/latency-investigation.md`
4. `investigations/incidents/`
5. `architecture/adrs/`
6. `demo/RUN.md`

---

## Example Investigation

A major investigation documented in this repository involved claim analysis requests averaging approximately 11–12 seconds.

Using OpenTelemetry, Jaeger, and Locust, the investigation identified repeated Python import costs as the primary source of latency.

The analysis resulted in a migration from a subprocess-per-request architecture to a long-running analyzer service.

Supporting documentation is available in:

* `investigations/latency-investigation.md`
* `investigations/incidents/INC-003-python-import-bottleneck/`
* `architecture/adrs/ADR-004-long-running-analyzer.md`

---

## Running the Demo

See `demo/RUN.md`.

---

## Disclaimer

This repository uses synthetic claims, sample policies, and development environments for demonstration purposes.

No production patient information or customer data is included.

See [DISCLAIMER.md](./DISCLAIMER.md) for additional information.

---

## Author

**Udonsi Kalu**

Platform engineering, observability, reliability engineering, and AI systems work documented through the development and operation of CXR.

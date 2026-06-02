# CXR — Claims Reasoning Platform (Engineering Portfolio)

This repository documents the architecture, observability, reliability, performance investigations, and operational practices developed while building and operating CXR (Claim eXamination & Reasoning).

CXR is a healthcare-focused claims analysis platform used as a case study for platform engineering, observability, load testing, reliability engineering, and AI systems operations.

The purpose of this repository is to document engineering work, decisions, investigations, and outcomes using a real system rather than isolated demonstrations.

---

## Repository Objectives

This repository focuses on:

* System architecture
* Platform operations
* OpenTelemetry instrumentation
* Jaeger tracing
* Load testing with Locust
* Reliability engineering
* Incident investigations
* Architecture Decision Records (ADRs)
* Kubernetes and infrastructure planning
* AI systems operations

---

## What This Repository Contains

| Area          | Description                                                   |
| ------------- | ------------------------------------------------------------- |
| Architecture  | System design, request flows, C4 diagrams, dependency mapping |
| Observability | OpenTelemetry, Jaeger, Prometheus, Grafana, trace analysis    |
| Reliability   | Incidents, postmortems, runbooks, SLOs, chaos experiments     |
| Operations    | Docker, CI/CD, Kubernetes, Terraform, deployment practices    |
| Security      | Security architecture, secrets management, risk assessment    |
| ADRs          | Engineering decisions and tradeoff analysis                   |
| Demo          | Reproducible local environment and walkthroughs               |

---

## Reviewer Guide

Recommended review order:

1. `my-impact.md`
2. `architecture/request-flow.md`
3. `observability/latency-investigation.md`
4. `reliability/incidents/`
5. `adrs/`
6. `demo/RUN.md`

---

## Example Investigation

One of the investigations documented in this repository involved claim analysis requests averaging approximately 11–12 seconds.

Using:

* OpenTelemetry
* Jaeger
* Locust

the investigation identified repeated Python import costs as the primary source of latency.

The analysis resulted in a migration from a subprocess-per-request architecture to a long-running analyzer service.

Supporting documentation is available in:

* `observability/latency-investigation.md`
* `reliability/incidents/INC-003-python-import-bottleneck/`
* `adrs/ADR-004-long-running-analyzer.md`

---

## Repository Structure

### Architecture

* C4 Context Diagram
* C4 Container Diagram
* C4 Component Diagram
* Request Flow
* Dependency Mapping
* Blast Radius Analysis
* Future State Architecture

### Platform Thinking

* Engineering Philosophy
* Design Principles
* Tradeoffs
* Architecture Evolution
* Platform Roadmap

### Observability

* OpenTelemetry
* Jaeger
* Prometheus
* Grafana
* Load Testing Results
* Latency Investigations

### Reliability

* Incidents
* Postmortems
* Runbooks
* SLOs and SLIs
* Chaos Experiments

### Operations

* Docker
* GitHub Actions
* CI/CD
* Kubernetes
* Terraform
* Capacity Planning
* Disaster Recovery

### Security

* Security Architecture
* Secrets Management
* Data Lifecycle
* Risk Assessment

### ADRs

Architecture Decision Records documenting key engineering decisions and tradeoffs.

---

## Running the Demo

See:

`demo/RUN.md`

for instructions on running the local demonstration environment.

---

## Disclaimer

This repository contains:

* Synthetic claims
* Sample policies
* Demonstration environments
* Development configurations

No production patient information or customer data is included.

See `DISCLAIMER.md` for additional information.

---

## Author

**Udonsi Kalu**

Engineering portfolio documenting the development and operation of CXR as a platform engineering and AI systems case study.

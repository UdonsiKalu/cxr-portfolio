# CXR — Claims Reasoning Platform (Engineering Portfolio)

> **Private work in progress** — full outline is populated; refine evidence, then set the repo public and pin on your profile. Status: [PORTFOLIO-STATUS.md](./PORTFOLIO-STATUS.md)

**Not a skills list. An implementation story.**

This repository documents how **CXR (Claim eXamination & Reasoning)** was designed, instrumented, load-tested, and operated in a real local platform stack: Next.js Claim Studio, a warm Python analyzer service, OpenTelemetry, Jaeger, Locust, Docker labs, and CI.

If you are hiring, partnering, or reviewing my work: start here, then follow the **10-minute path** below.

---

## What this repo is

| It is | It is not |
|-------|-----------|
| Evidence of **engineering decisions** (ADRs, incidents, traces) | A generic “I know Kubernetes” resume bullet list |
| **Screenshots and timelines** from real investigations | Production customer data (synthetic claims only) |
| A map of **how the system runs** and how we proved latency | The full proprietary CXR product monorepo |

Companion implementation repos (when published): `cxr-ui-rehearsal`, `cxr-ops-lab`, `claim_analysis_tools`.

---

## 10-minute reviewer path

1. **[my-impact.md](./my-impact.md)** — outcomes in plain language (~11s → ~2s analyze, traceability)
2. **[observability/latency-investigation.md](./observability/latency-investigation.md)** — Locust + Jaeger proof
3. **[reliability/incidents/INC-003-python-import-bottleneck/postmortem.md](./reliability/incidents/INC-003-python-import-bottleneck/postmortem.md)** — warm analyzer decision
4. **[observability/screenshots/](./observability/screenshots/)** — Jaeger waterfalls
5. **[demo/RUN.md](./demo/RUN.md)** — run the stack locally (for technical reviewers)

---

## Full index

See **[INDEX.md](./INDEX.md)** for maturity (complete vs scaffold) and **[STRUCTURE.md](./STRUCTURE.md)** for the full portfolio tree.

The repo includes the **full outline** with content in every section. Chaos game-days and diagram PNGs are **planned runs** until you add evidence.

---

## Highlights by theme

### Architecture
- [Request flow](./architecture/request-flow.md) — browser → Next.js → analyzer → kernel
- [C4 context](./architecture/c4-context.md) · [C4 containers](./architecture/c4-container.md)

### Observability (recent focus)
- [Overview](./observability/observability-overview.md)
- [OpenTelemetry](./observability/opentelemetry.md) · [Jaeger](./observability/jaeger.md)
- [Load testing results](./observability/load-testing-results.md)

### Reliability
- [INC-001 High API latency](./reliability/incidents/INC-001-high-latency/)
- [INC-002 Jaeger trace UX](./reliability/incidents/INC-002-jaeger-trace-ux/)
- [INC-003 Python import bottleneck](./reliability/incidents/INC-003-python-import-bottleneck/)

### Operations
- [Restart stack](./operations/restart-stack.md) — one-command dev (`cxr up`)
- [Docker & compose](./operations/docker.md) · [CI/CD](./operations/ci-cd.md)

### Architecture decisions
- [ADRs](./adrs/) — subprocess vs warm worker, OTel, Qdrant, K8 roadmap

### Platform thinking
- [Engineering philosophy](./platform-thinking/engineering-philosophy.md)
- [Architecture journey](./platform-thinking/architecture-journey/) — v1 → observability → load → reliability

---

## Run it yourself

Technical reviewers can reproduce the **observe + Claim Studio + load** path:

**[demo/RUN.md](./demo/RUN.md)**

---

## Disclaimer

Read **[DISCLAIMER.md](./DISCLAIMER.md)** — synthetic data, local dev tokens, bootcamp lab scaffolds.

---

## Author

**Udonsi Kalu** — platform-minded full-stack / claims-adjacent systems work documented here for public review.

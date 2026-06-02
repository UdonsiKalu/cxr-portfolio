# CXR — Claims Reasoning Platform (Engineering Portfolio)

This repository documents how **CXR (Claim eXamination & Reasoning)** was designed, investigated, and operated: architecture, performance work, incidents, and a runnable local demo.

CXR is a healthcare-focused claims analysis platform used as a case study for platform engineering, observability, load testing, and reliability work on a real stack (not toy demos).

---

## Start here (reviewers)

| Step | Document |
|------|----------|
| 1 | [my-impact.md](./my-impact.md) — outcomes in plain language |
| 2 | [architecture/request-flow.md](./architecture/request-flow.md) — how a claim moves through the system |
| 3 | [investigations/latency-investigation.md](./investigations/latency-investigation.md) — Locust + Jaeger proof |
| 4 | [investigations/incidents/INC-003-python-import-bottleneck/postmortem.md](./investigations/incidents/INC-003-python-import-bottleneck/postmortem.md) — warm analyzer decision |
| 5 | [demo/RUN.md](./demo/RUN.md) — run it locally (optional) |

**Flagship story:** ~11s analyze requests → traced to Python import cost → long-running analyzer → **~2s** warm path. See [architecture/adrs/ADR-004-long-running-analyzer.md](./architecture/adrs/ADR-004-long-running-analyzer.md).

---

## Repository layout (five folders)

```
cxr-portfolio/
├── README.md
├── my-impact.md
├── DISCLAIMER.md
├── architecture/      # Design, C4, ADRs, evolution
├── investigations/    # Traces, latency, incidents, runbooks, chaos
├── operations/        # Docker, CI/CD, Kubernetes, Terraform
├── demo/              # Run instructions, compose, walkthroughs
└── archive/           # Templates, notes, maintainer docs (optional)
```

| Folder | What’s inside |
|--------|----------------|
| **architecture/** | C4 diagrams, request flow, engineering philosophy, tradeoffs, **adrs/** |
| **investigations/** | OpenTelemetry, Jaeger, latency work, **incidents/**, runbooks, screenshots |
| **operations/** | `cxr up`, Docker, GitHub Actions, K8 and Terraform reference |
| **demo/** | Reproduce the observe + Claim Studio path |
| **archive/** | Bootcamp notes, templates, security drafts — not required for review |

---

## Disclaimer

Synthetic claims and local dev configuration only. No production patient data. See [DISCLAIMER.md](./DISCLAIMER.md).

---

## Author

**Udonsi Kalu** — engineering portfolio for CXR as a platform and AI-systems case study.

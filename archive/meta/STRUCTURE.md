# Repository structure (maintainers)

This tree matches the **CXR engineering portfolio outline**. All paths contain **written content** sourced from CXR work (vault, ops-lab, incidents).

See [PORTFOLIO-STATUS.md](./PORTFOLIO-STATUS.md) for promotion checklist.

| Badge | Meaning |
|-------|---------|
| **Complete** | Ready for reviewer (evidence-backed) |
| **Planned runs** | Procedure written; execute lab (e.g. chaos) before public claim |
| **Reference** | Copy or pointer to `cxr-ops-lab` / companion repos |

```
cxr-portfolio/
├── README.md
├── DISCLAIMER.md
├── my-impact.md
├── meta/                 ← INDEX, STRUCTURE, PORTFOLIO-STATUS (maintainers)
│
├── architecture/
│   ├── c4-context.md … c4-component.md, request-flow.md, …
│   └── diagrams/         ← PNGs planned (README lists names)
│
├── architecture/
│   ├── engineering-philosophy.md …
│   ├── architecture-journey/   (v1 … future-state)
│   └── platform-model/
│
├── investigations/
│   ├── … (overview, OTel, Jaeger, latency, load testing)
│   ├── dashboards/
│   └── screenshots/      ← SW.11 Jaeger PNGs
│
├── reliability/
│   ├── slos-and-slis.md …
│   ├── incidents/        ← INC-001/003 complete; INC-002 Jaeger evidenced
│   ├── chaos-experiments/  (scaffold until game days)
│   └── runbooks/
│
├── operations/
│   ├── docker.md, ci-cd.md, …
│   ├── kubernetes/       ← reference YAML from cxr-ops-lab
│   └── terraform/
│
├── archive/security-compliance/
├── adrs/                 ← ADR-001–006
├── demo/
├── archive/
└── templates/
```

**Incidents:** [INC-002-jaeger-trace-ux](../investigations/incidents/INC-002-jaeger-trace-ux/postmortem.md) (trace profile / span visibility).

Bootcamp lab index: [archive/learning-notes/bootcamp-labs.md](../archive/learning-notes/bootcamp-labs.md).

# Repository structure

This tree matches the **CXR engineering portfolio outline**. All paths contain **written content** sourced from CXR work (vault, ops-lab, incidents).

**Repository:** Private until you promote — see [PORTFOLIO-STATUS.md](./PORTFOLIO-STATUS.md).

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
├── INDEX.md
├── STRUCTURE.md          ← this file
│
├── architecture/
│   ├── c4-context.md … c4-component.md, request-flow.md, …
│   └── diagrams/         ← PNGs planned (README lists names)
│
├── platform-thinking/
│   ├── engineering-philosophy.md …
│   ├── architecture-journey/   (v1 … future-state)
│   └── platform-model/
│
├── observability/
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
├── security-compliance/  (scaffold)
├── adrs/                 ← ADR-001–004 complete; 005–006 scaffold
├── demo/
├── archive/
└── templates/
```

**Incidents:** [INC-002-jaeger-trace-ux](./reliability/incidents/INC-002-jaeger-trace-ux/postmortem.md) (trace profile / span visibility).

`bootcamp-labs.md` at repo root; copy also under [archive/learning-notes/](./archive/learning-notes/).

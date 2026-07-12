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
├── CHANGELOG.md
├── failures/
├── reliability/
├── investigations/
│   ├── README.md
│   ├── … study folders …
│   └── planned/
├── operations/
│   ├── docker.md, ci-cd.md, …
│   ├── kubernetes/
│   └── terraform/
└── archive/
    ├── architecture/          ← ADRs (ADR-001–006)
    ├── architecture-c4/       ← C4 / evolution diagrams
    ├── architecture-supplemental/
    ├── reviewer/              ← hiring/academic pack
    ├── demo/
    ├── old-investigations/
    ├── meta/                  ← INDEX, STRUCTURE, PORTFOLIO-STATUS
    └── …
```

Trace profile notes: [investigations/README.md#trace-profiles](../investigations/README.md#trace-profiles).

Bootcamp lab index: [archive/learning-notes/bootcamp-labs.md](../archive/learning-notes/bootcamp-labs.md).

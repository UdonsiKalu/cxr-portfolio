# Architecture decisions (ADRs)

**Architecture Decision Records** capture *why* CXR was built a certain way — durable until superseded by a newer ADR.

Canonical files live in [`architecture/adrs/`](../architecture/adrs/). This page is the **reviewer index**.

---

## How to read an ADR

Each record typically covers: **context**, **decision**, **consequences**, and **status**. ADRs are point-in-time; see [CHANGELOG](../CHANGELOG.md) for later changes that may outpace a single ADR.

---

## Index

| ADR | Topic | Status |
|-----|-------|--------|
| [ADR-001](../architecture/adrs/ADR-001-qdrant.md) | Qdrant for semantic retrieval | Accepted |
| [ADR-002](../architecture/adrs/ADR-002-opentelemetry.md) | OpenTelemetry tracing | Accepted |
| [ADR-003](../architecture/adrs/ADR-003-python-subprocess.md) | Subprocess analyzer (superseded) | Superseded by ADR-004 |
| [ADR-004](../architecture/adrs/ADR-004-long-running-analyzer.md) | Long-running analyzer on :8766 | **Flagship** — read first |
| [ADR-005](../architecture/adrs/ADR-005-kubernetes-roadmap.md) | Kubernetes deployment roadmap | Accepted |
| [ADR-006](../architecture/adrs/ADR-006-monolith-vs-microservices.md) | Monolith vs microservices framing | Accepted |

**Load / scale note:** GATE-002 operational findings (UI `maxReplicas=4`, analyzer `maxReplicas=8`) are evidenced in [tuner summary](../investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json) and [failures index](../failures/README.md); consider a future ADR when promoted to git-managed Helm defaults.

---

## Related

- [Architecture overview](../architecture/README.md)  
- [Architecture evolution](../architecture/architecture-evolution.md)  
- [Development history](history.md)

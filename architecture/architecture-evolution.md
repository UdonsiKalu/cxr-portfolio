# Architecture evolution

How CXR moved from a subprocess-per-request analyze path to a warm analyzer, observable stack, and operator-friendly dev workflow—and the principles that guided those choices.

---

## Engineering philosophy

### Show the implementation

Skills on a profile are claims. **Traces, ADRs, load tests, and runbooks** are proof. This portfolio exists because CXR work produced measurable outcomes—not because a checklist of tools was memorized.

### Measure before optimizing

The **~10s vs ~1.5s** story only makes sense with Jaeger and Locust together. Optimizing `context_builder` without fixing process architecture would have been a waste.

### Operability is a feature

If only one engineer can start the stack from memory, the system is not ready for collaboration. **`cxr up`** is part of the product of engineering.

### Honest scope

Bootcamp labs (Kafka, Vault, …) are **learning infrastructure**, not implied production deployments. Documents say when something is scaffold vs shipped.

### Default to detailed observability

When trace profiles trade away debuggability for aesthetics, **reject the trade** unless SLO dashboards truly require it (they did not, here).

---

## Design principles

1. **Evidence over claims** — traces, ADRs, load tests beat tool lists.
2. **Measure before optimize** — Jaeger + Locust before tuning `context_builder`.
3. **Operability** — `cxr up` so any engineer can reproduce investigations.
4. **Honest scope** — label bootcamp labs vs daily dev path.
5. **Detailed observability by default** — reject “minimal” trace profiles that hide startup/import cost.

---

## Evolution timeline

### v1 — Subprocess / monolith path

Analyze via spawned Python per HTTP request. Simple mental model; terrible p95 under load.

**Evidence:** [investigations/latency-investigation/latency-investigation.md](../investigations/latency-investigation/latency-investigation.md) · [investigations/incidents/](../investigations/incidents/)

### v2 — Observability

OTel on Next.js + Python; Jaeger at **:16686**; discovered import/init dominance.

**Evidence:** [investigations/latency-investigation/latency-investigation.md](../investigations/latency-investigation/latency-investigation.md) · [investigations/incidents/](../investigations/incidents/)

### v3 — Load testing

Locust on **:8251**; correlated p95 with trace waterfalls.

**Evidence:** [investigations/latency-investigation/latency-investigation.md](../investigations/latency-investigation/latency-investigation.md) · [investigations/load-testing/load-testing-results.md](../investigations/load-testing/load-testing-results.md)

### v4 — Reliability

Warm analyzer on **:8766**, runbooks, `cxr` CLI, incidents INC-001–003.

**Evidence:** [investigations/incidents/INC-003-python-import-bottleneck/postmortem.md](../investigations/incidents/INC-003-python-import-bottleneck/postmortem.md) · [adrs/ADR-004-long-running-analyzer.md](./adrs/ADR-004-long-running-analyzer.md)

---

## Tradeoffs

| Decision | Chosen | Alternative | Why |
|----------|--------|-------------|-----|
| Analyze runtime | Warm FastAPI **:8766** | Subprocess per request | ~7–8s import/init removed from hot path |
| Trace profile | `detailed` | `minimal` | Fewer confusing Operations; ~21 useful spans |
| Daily UI | **:8251** rehearsal | **:3000** compose only | Faster iteration + OTel on dev route |
| Qdrant | Optional in dev | Hard dependency | Local laptops may skip vector stack |
| Portfolio repo | Private until ready | Public + empty scaffolds | Reviewer path credible before promotion |

---

## Diagrams

Export PNGs to [diagrams/](./diagrams/) when ready (`c4-context.png`, `request-flow.png`, etc.). Supplemental markdown sources (component view, dependency map, blast radius) live in [../archive/architecture-supplemental/](../archive/architecture-supplemental/).

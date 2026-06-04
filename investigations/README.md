# Investigations

<!-- portfolio -->

Engineering investigations on the CXR dev stack — each **folder is one question we ran (or will run)**. Concepts (performance, load, reliability, chaos, observability) are described here; folders hold evidence.

**Execution order:** [roadmap.md](./roadmap.md)

---

## Concepts (how to read this portfolio)

| Concept | What it means here | Example in CXR |
|---------|-------------------|----------------|
| **Performance** | Where time goes in the analyze path | Subprocess imports → warm analyzer on :8766 |
| **Load testing** | Client-side latency under concurrent users | Locust p95 on `POST /analyze` |
| **Tracing** | Single-request span breakdown | Jaeger: outer HTTP vs `context_builder` |
| **Reliability** | Behavior when a dependency or process fails | Qdrant down, analyzer killed |
| **Chaos** | Deliberate fault injection under traffic | Kill :8766 during Locust swarm |
| **Observability** | Can telemetry be trusted for incidents? | Trace profiles, propagation UI → analyzer |
| **Incidents** | Postmortem record after impact | [postmortems/](./postmortems/) |

> **Two metrics, two lenses:** Locust p50/p95 (aggregate under load) ≠ Jaeger duration on one trace. Never conflate them.

---

## Completed

| Investigation | Folder |
|---------------|--------|
| Claim analysis latency (subprocess → warm analyzer) | [latency-investigation/](./latency-investigation/) |
| Locust load baseline (before/after) | [load-testing/](./load-testing/) |
| Missing spans / trace profile UX | [missing-spans/](./missing-spans/) |
| Postmortems (INC-001–003) | [postmortems/](./postmortems/) |

---

## Phase 1 — run next

| # | Investigation | Folder |
|---|---------------|--------|
| 1 | Cold vs warm analyzer | [cold-vs-warm-analyzer/](./cold-vs-warm-analyzer/) |
| 2 | Single analyzer capacity | [single-analyzer-capacity/](./single-analyzer-capacity/) |
| 3 | Analyzer saturation point | [analyzer-saturation/](./analyzer-saturation/) |
| 4 | Kill analyzer under traffic (+ recovery) | [kill-analyzer-under-traffic/](./kill-analyzer-under-traffic/) |
| 5 | Qdrant outage | [qdrant-outage/](./qdrant-outage/) |
| 6 | End-to-end trace propagation | [trace-propagation/](./trace-propagation/) |
| 7 | Platform bootstrap (one-command stack) | [planned/platform-bootstrap.md](./planned/platform-bootstrap.md) → promote to folder when done |

---

## Backlog

[planned/](./planned/) — future investigations as short markdown stubs (not empty folder trees).

---

## Report template

Question → Hypothesis → Method → Tools → Metrics → Results → Findings → Decision → Follow-up

---

## Tools

- [jaeger.md](./jaeger.md)
- [locust.md](./locust.md)
- [opentelemetry.md](./opentelemetry.md)

Supplemental: [../archive/investigations-supplemental/](../archive/investigations-supplemental/)

Revert layout: [RESTRUCTURE.md](./RESTRUCTURE.md)

# Investigation roadmap

<!-- portfolio -->

Phase 1 is the **evidence path** — run these in order on the local CXR stack (`cxr-dev.sh up`, Locust, Jaeger). Phase 2 lives under [planned/](./planned/) (ideas not yet run).

## Story

Fixed analyze latency → measured warm vs cold behavior → found single-instance capacity and saturation → killed the analyzer under traffic → tested dependency failure → validated end-to-end traces → (next) document one-command platform bootstrap.

## Phase 1 — execution order

| Step | ID | Report | Status |
|------|-----|--------|--------|
| — | **PERF-001** | [latency-investigation/](./latency-investigation/) | ✅ Complete |
| — | **LOAD baseline** | [load-testing/](./load-testing/) | ✅ Complete |
| — | **OBS-001** | [observability/OBS-001-missing-spans/](./observability/OBS-001-missing-spans/) | ✅ Complete |
| — | **INC-001–003** | [incidents/](./incidents/) | ✅ Complete |
| 1 | **PERF-004** | [performance/PERF-004-cold-vs-warm-analyzer/](./performance/PERF-004-cold-vs-warm-analyzer/) | 🔜 Next |
| 2 | **LOAD-001** | [load-capacity/LOAD-001-single-analyzer-capacity/](./load-capacity/LOAD-001-single-analyzer-capacity/) | Planned |
| 3 | **LOAD-002** | [load-capacity/LOAD-002-analyzer-saturation-point/](./load-capacity/LOAD-002-analyzer-saturation-point/) | Planned |
| 4 | **CHAOS-001** | [chaos-experiments/CHAOS-001-kill-analyzer/](./chaos-experiments/CHAOS-001-kill-analyzer/) | Planned |
| 5 | **REL-003** | [reliability/REL-003-analyzer-crash/](./reliability/REL-003-analyzer-crash/) | Planned (same run as CHAOS-001 — recovery) |
| 6 | **REL-001** | [reliability/REL-001-qdrant-outage/](./reliability/REL-001-qdrant-outage/) | Planned |
| 7 | **OBS-002** | [observability/OBS-002-trace-propagation/](./observability/OBS-002-trace-propagation/) | Planned |
| 8 | **PLATFORM-001** | [planned/platform/PLATFORM-001-platform-bootstrap.md](./planned/platform/PLATFORM-001-platform-bootstrap.md) | Planned (pull to active folder when written) |

> **Metrics rule:** Locust p50/p95 (aggregate under load) ≠ Jaeger single-trace duration. Report both separately.

## Phase 2 — backlog

See [planned/README.md](./planned/README.md).

## Investigation template

Each active report uses: Question → Hypothesis → Method → Tools → Metrics → Results → Findings → Decision → Follow-up.

## Tools

- [jaeger.md](./jaeger.md)
- [locust.md](./locust.md)
- [opentelemetry.md](./opentelemetry.md)

Supplemental (Prometheus, Grafana, SLO drafts): [../archive/investigations-supplemental/](../archive/investigations-supplemental/)

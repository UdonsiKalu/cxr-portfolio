# Investigations

Engineering investigations for CXR — performance, load, reliability, chaos, observability, platform, and cost. Each ID gets a folder when there is a question worth answering; **completed** work has evidence (report + screenshots).

## Investigation pattern

| Section | Purpose |
|---------|---------|
| **Question** | What are we trying to learn? |
| **Hypothesis** | What we expect before running |
| **Method** | Steps to reproduce |
| **Tools** | Locust, Jaeger, OTel, etc. |
| **Metrics** | What we measure (Locust p95 vs Jaeger trace duration) |
| **Results** | What happened |
| **Findings** | Interpretation |
| **Decision** | ADR, architecture change, or defer |
| **Follow-up** | Next ID or backlog |

---

## Completed reports (evidence-backed)

| ID | Report | Notes |
|----|--------|-------|
| **PERF-001** | [latency-investigation/](./latency-investigation/) | 11–12s → warm analyzer; [screenshots](./latency-investigation/screenshots/) |
| **LOAD baseline** | [load-testing/load-testing-results.md](./load-testing/load-testing-results.md) | Locust p95 table; [screenshots](./load-testing/screenshots/) |
| **OBS-001** | [observability/OBS-001-missing-spans/completed.md](./observability/OBS-001-missing-spans/completed.md) | Trace profile `minimal` → `detailed` |
| **INC-003** | [incidents/INC-003-python-import-bottleneck/postmortem.md](./incidents/INC-003-python-import-bottleneck/postmortem.md) | Import bottleneck incident |

Index entries: [performance/PERF-001/](./performance/PERF-001-claim-analysis-latency/completed.md)

---

## Taxonomy (planned unless marked complete above)

### [performance/](./performance/)

| ID | Folder | Status |
|----|--------|--------|
| PERF-001 | [PERF-001-claim-analysis-latency/](./performance/PERF-001-claim-analysis-latency/) | **Completed** |
| PERF-002 | [PERF-002-context-builder-optimization/](./performance/PERF-002-context-builder-optimization/) | Planned |
| PERF-003 | [PERF-003-qdrant-retrieval-scaling/](./performance/PERF-003-qdrant-retrieval-scaling/) | Planned |
| PERF-004 | [PERF-004-cold-vs-warm-analyzer/](./performance/PERF-004-cold-vs-warm-analyzer/) | Planned |

### [load-capacity/](./load-capacity/)

| ID | Folder | Status |
|----|--------|--------|
| LOAD-001 | [LOAD-001-single-analyzer-capacity/](./load-capacity/LOAD-001-single-analyzer-capacity/) | Planned |
| LOAD-002 | [LOAD-002-analyzer-saturation-point/](./load-capacity/LOAD-002-analyzer-saturation-point/) | Planned |
| LOAD-003 | [LOAD-003-horizontal-scaling/](./load-capacity/LOAD-003-horizontal-scaling/) | Planned |

Baseline load test (Locust): [load-testing/](./load-testing/)

### [reliability/](./reliability/)

| ID | Folder | Status |
|----|--------|--------|
| REL-001 | [REL-001-qdrant-outage/](./reliability/REL-001-qdrant-outage/) | Planned |
| REL-002 | [REL-002-ollama-outage/](./reliability/REL-002-ollama-outage/) | Planned |
| REL-003 | [REL-003-analyzer-crash/](./reliability/REL-003-analyzer-crash/) | Planned |
| REL-004 | [REL-004-database-unavailable/](./reliability/REL-004-database-unavailable/) | Planned |

### [chaos-experiments/](./chaos-experiments/)

| ID | Folder | Status |
|----|--------|--------|
| CHAOS-001 | [CHAOS-001-kill-analyzer/](./chaos-experiments/CHAOS-001-kill-analyzer/) | Planned |
| CHAOS-002 | [CHAOS-002-network-latency/](./chaos-experiments/CHAOS-002-network-latency/) | Planned |
| CHAOS-003 | [CHAOS-003-packet-loss/](./chaos-experiments/CHAOS-003-packet-loss/) | Planned |
| CHAOS-004 | [CHAOS-004-cpu-starvation/](./chaos-experiments/CHAOS-004-cpu-starvation/) | Planned |

### [observability/](./observability/)

| ID | Folder | Status |
|----|--------|--------|
| OBS-001 | [OBS-001-missing-spans/](./observability/OBS-001-missing-spans/) | **Completed** |
| OBS-002 | [OBS-002-trace-propagation/](./observability/OBS-002-trace-propagation/) | Planned |
| OBS-003 | [OBS-003-alerting-strategy/](./observability/OBS-003-alerting-strategy/) | Planned |

### [platform/](./platform/)

| ID | Folder | Status |
|----|--------|--------|
| PLATFORM-001 | [PLATFORM-001-monolith-vs-microservices/](./platform/PLATFORM-001-monolith-vs-microservices/) | Planned |
| PLATFORM-002 | [PLATFORM-002-kubernetes-migration/](./platform/PLATFORM-002-kubernetes-migration/) | Planned |
| PLATFORM-003 | [PLATFORM-003-load-balancing/](./platform/PLATFORM-003-load-balancing/) | Planned |
| PLATFORM-004 | [PLATFORM-004-autoscaling/](./platform/PLATFORM-004-autoscaling/) | Planned |

### [cost/](./cost/)

| ID | Folder | Status |
|----|--------|--------|
| COST-001 | [COST-001-cost-per-claim/](./cost/COST-001-cost-per-claim/) | Planned |
| COST-002 | [COST-002-gpu-utilization/](./cost/COST-002-gpu-utilization/) | Planned |
| COST-003 | [COST-003-analyzer-efficiency/](./cost/COST-003-analyzer-efficiency/) | Planned |

### [incidents/](./incidents/)

| ID | Folder |
|----|--------|
| INC-001 | [INC-001-high-latency/](./incidents/INC-001-high-latency/) |
| INC-002 | [INC-002-jaeger-trace-ux/](./incidents/INC-002-jaeger-trace-ux/) |
| INC-003 | [INC-003-python-import-bottleneck/](./incidents/INC-003-python-import-bottleneck/) |

---

## Tool references

- [jaeger.md](./jaeger.md) — read traces
- [opentelemetry.md](./opentelemetry.md) — instrumentation
- [locust.md](./locust.md) — load testing

Supplemental notes (Prometheus, Grafana, SLO drafts): [../archive/investigations-supplemental/](../archive/investigations-supplemental/)

# Risk register

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|------------|--------|------------|
| R1 | Subprocess fallback reintroduced | Med | High p95 | ADR-004; check `analyzer_mode` |
| R2 | Qdrant optional down | High | Low–Med | WARN documented; retrieval degraded |
| R3 | Trace profile “minimal” | Low | High debug cost | Default `detailed` |
| R4 | Docker observe hang | Med | No traces | Restart Docker; `cxr down --observe-down` |

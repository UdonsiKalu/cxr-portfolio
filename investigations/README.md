# Investigations

Each major investigation gets its **own folder** with a write-up (`.md`) and **`screenshots/`** subfolder — same pattern as `chaos-experiments/`.

| Folder | Topic | Entry doc |
|--------|-------|-----------|
| [latency-investigation/](./latency-investigation/) | Locust + Jaeger → root cause → warm **:8766** | [latency-investigation.md](./latency-investigation/latency-investigation.md) |
| [load-testing/](./load-testing/) | Locust setup, p95 table, how to read with Jaeger | [load-testing-results.md](./load-testing/load-testing-results.md) |
| [chaos-experiments/](./chaos-experiments/) | Planned game-day experiments | `EXP-*.md` |
| [incidents/](./incidents/) | INC-001–003 postmortems | `*/postmortem.md` |

**Shared tool context** (not full investigations yet): [jaeger.md](./jaeger.md), [opentelemetry.md](./opentelemetry.md), [observability-overview.md](./observability-overview.md).

**Planned folders:** `opentelemetry-investigation/`, `observability-investigation/` (when evidenced).

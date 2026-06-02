# Design principles

1. **Evidence over claims** — traces, ADRs, load tests beat tool lists.
2. **Measure before optimize** — Jaeger + Locust before tuning `context_builder`.
3. **Operability** — `cxr up` so any engineer can reproduce investigations.
4. **Honest scope** — label bootcamp labs vs daily dev path.
5. **Detailed observability by default** — reject “minimal” trace profiles that hide startup/import cost.

See [engineering-philosophy.md](./engineering-philosophy.md).

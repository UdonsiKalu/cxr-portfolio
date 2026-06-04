# PERF-002 — Context builder optimization

**Status:** Planned (Phase 2)

| Field | |
|-------|---|
| **Question** | TBD — where does time go inside warm `context_builder` spans? |
| **Hypothesis** | TBD |
| **Method** | Jaeger span breakdown on varied claim payloads |
| **Tools** | Jaeger, Locust |
| **Metrics** | `context_builder` duration vs outer HTTP span |

## Results

Not yet run.

## Follow-up

After [LOAD-002](../../load-capacity/LOAD-002-analyzer-saturation-point/) — only optimize if context builder is the next bottleneck.

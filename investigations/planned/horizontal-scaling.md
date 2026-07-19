# LOAD-003 — Horizontal scaling (1 vs N analyzers)

**Status:** Done → [../kubernetes-analyzer-saturation/](../kubernetes-analyzer-saturation/) (issue [#8](https://github.com/UdonsiKalu/cxr-portfolio/issues/8) closed)

| Field | |
|-------|---|
| **Question** | Does adding analyzer instances improve throughput / p95 under load? |
| **Where it landed** | Kubernetes HPA + Locust on `:8081` — [LOAD-003 README](../kubernetes-analyzer-saturation/README.md) |
| **Related** | [studies index](../kubernetes-analyzer-saturation/studies/README.md) · [load-balancing](./load-balancing.md) (still open) |

## Note

The original “1 vs 3 local processes” sketch was superseded by the K8 saturation arc (replicas + HPA). Keep this stub only as a pointer.

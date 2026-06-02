# C4 — Containers (local dev)

```mermaid
flowchart TB
  subgraph host [Host_processes]
    ui[NextJS_cxr_ui_dev_8251]
    py[FastAPI_analyzer_8766]
    locust[Locust_8089]
  end
  subgraph docker [Docker_observe]
    collector[otel_collector_4318]
    jaeger[jaeger_16686]
    prom[prometheus_9090]
    grafana[grafana_3001]
  end
  sql[(SQLServer)]
  qdrant[(Qdrant_6333)]

  ui -->|HTTP_analyze| py
  locust -->|load_8251| ui
  ui --> collector
  py --> collector
  collector --> jaeger
  py --> sql
  py --> qdrant
```

## Containers / processes

| Name | Technology | Notes |
|------|------------|-------|
| Claim Studio UI | Next.js 16 | Rehearsal/dev tree on **8251** |
| Analyzer service | FastAPI + uvicorn | Warm worker on **8766** |
| OTel Collector | Docker | Receives OTLP, exports to Jaeger |
| Jaeger | Docker | Trace UI |
| Locust | Python venv | Load generator UI **8089** |

## Optional bootcamp labs (Docker only)

Kafka, ELK, Redis, GraphQL, gRPC, Vault, Langfuse — started via `cxr lab up <name>`. See [bootcamp-labs.md](../archive/learning-notes/bootcamp-labs.md).

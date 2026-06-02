# Bootcamp labs (optional Docker stacks)

Started with **`cxr lab up <name>`** — not part of default **`cxr up`**.

| Lab | Command | Main URLs |
|-----|---------|-----------|
| Kafka | `cxr lab up kafka` | UI http://localhost:8082 · broker :9092 |
| ELK | `cxr lab up elk` | Kibana http://localhost:5601 · ES :9200 |
| Redis | `cxr lab up redis` | redis://localhost:6379 · Insight http://localhost:5540 |
| GraphQL | `cxr lab up graphql` | http://localhost:4000/graphql |
| gRPC | `cxr lab up grpc` | grpcui http://localhost:8090 · gRPC :50051 |
| Vault | `cxr lab up vault` | http://localhost:8200 |
| Langfuse | `cxr lab up langfuse` | http://localhost:3100 |

Stop: `cxr lab down <name>`

List: `cxr lab list`

These are **syllabus exercises** — documented here for completeness, not required for Claim Studio + Jaeger daily path.

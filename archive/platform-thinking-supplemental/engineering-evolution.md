# Engineering evolution

1. **Subprocess analyze** — worked but hid cost in new Python each request.
2. **OTel + Jaeger** — made subprocess vs kernel time visible (latency investigation).
3. **Warm analyzer** — ADR-004; Locust p95 ~1.5s, Jaeger traces ~154–708ms.
4. **Trace UX rollback** — detailed profile + `flush_tracing()`; see [trace profiles](../investigations/README.md#trace-profiles).
5. **One-command stack** — `cxr up` + optional `cxr lab` for syllabus.
6. **Next** — K8/Helm/Terraform/Argo evidence in ops-lab; portfolio documents, does not duplicate prod infra.

# Engineering evolution

1. **Subprocess analyze** — worked but hid cost in new Python each request.
2. **OTel + Jaeger** — made subprocess vs kernel time visible (INC-001, INC-003).
3. **Warm analyzer** — ADR-004; warm POST ~1.6–3s.
4. **Trace UX rollback** — INC-002; detailed profile + `flush_tracing()`.
5. **One-command stack** — `cxr up` + optional `cxr lab` for syllabus.
6. **Next** — K8/Helm/Terraform/Argo evidence in ops-lab; portfolio documents, does not duplicate prod infra.

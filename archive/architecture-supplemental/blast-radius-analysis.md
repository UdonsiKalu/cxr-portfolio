# Blast radius analysis

## Failure domains

| Failure | Blast radius | Mitigation | Evidence |
|---------|--------------|------------|----------|
| Analyzer :8766 down | Analyze API 500 / fetch failed; UI shell up | `cxr up`; health check :8766 | [kill-analyzer-under-traffic](../../archive/old-investigations/kill-analyzer-under-traffic/) |
| Jaeger / OTLP down | No new traces; app may still work | `cxr up` observe stack | — |
| SQL `:1433` unreachable | **Analyze + Terminal diag hard-fail (HTTP 500)**; UI pages still load | Fix network / unblock port / SQL health in readiness | **[REL-004](../../investigations/database-unavailable/)** |
| Qdrant down | Retrieval degraded; Compliant analyze may continue | Documented WARN / soft fallback | [qdrant-outage](../../archive/old-investigations/qdrant-outage/) |
| Ollama `:11434` down | Auditor/judge fails; Compliant Analyze often still 200 | Health-check Ollama for audit features | [REL-002](../../investigations/ollama-outage/) |
| Next.js :8251 down | UI unavailable | Restart `run-rehearsal-dev.sh` / `cxr up` | — |

## What we do not claim

This is a **local engineering stack**, not multi-tenant SaaS isolation. Blast radius for production K8 is tracked in [future-state-architecture.md](../../archive/architecture-c4/future-state-architecture.md) and [ADR-005](../../architecture/adrs/ADR-005-kubernetes-roadmap.md).

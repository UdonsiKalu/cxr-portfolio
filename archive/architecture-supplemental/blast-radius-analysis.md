# Blast radius analysis

## Failure domains

| Failure | Blast radius | Mitigation |
|---------|--------------|------------|
| Analyzer :8766 down | Analyze API slow or subprocess fallback | `cxr up`; health check :8766 |
| Jaeger / OTLP down | No new traces; app may still work | `cxr up` observe stack |
| SQL unreachable | Terminal + analyze rules fail | Fix connection string / VPN |
| Qdrant down | Retrieval degraded; core analyze may continue | Documented WARN in logs |
| Next.js :8251 down | UI unavailable | Restart `run-rehearsal-dev.sh` |

## What we do not claim

This is a **local engineering stack**, not multi-tenant SaaS isolation. Blast radius for production K8 is tracked in [future-state-architecture.md](../../archive/architecture-c4/future-state-architecture.md) and [ADR-005](../../archive/decisions/adrs/ADR-005-kubernetes-roadmap.md).

# ADR-006 — Monolith vs microservices (CXR dev)

## Status

Accepted for current portfolio scope.

## Decision

- **Monolith UI + warm analyzer service** for dev and evidence (not full platform gateway spine in daily path).
- Optional platform containers (gateway, analysis, kernel) documented in C4 Level 2 as **when deployed**, not required for Jaeger/latency story.

## Consequences

- Simpler reviewer path; microservice split deferred to K8/GitOps milestones.

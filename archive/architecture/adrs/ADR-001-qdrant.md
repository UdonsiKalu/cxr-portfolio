# ADR-001: Qdrant for policy / context retrieval

## Status

Accepted (with degraded-mode behavior)

## Context

CXR kernel retrieves policy chunks from **Qdrant** during `retrieval` stage. Local dev often has Qdrant **down** (`Connection refused` on :6333).

## Decision

Keep Qdrant as retrieval backend; allow analyze to continue with warnings and fast-fallback spans when unavailable.

## Consequences

- Jaeger may show **retrieval** as very fast with zero chunks.
- Production would require explicit health checks and SLO impact — documented for portfolio honesty.

## Follow-up

- Chaos experiment EXP-001 (planned) — Qdrant failure injection.

# Architecture

System design for CXR (Claim eXamination & Reasoning) — how components connect, how requests flow, and why key decisions were made.

## Core documents

| Document | Purpose |
|----------|---------|
| [c4-context.md](./c4-context.md) | System context (C4 L1) |
| [c4-container.md](./c4-container.md) | Containers and ports (C4 L2) |
| [request-flow.md](./request-flow.md) | Analyze path step-by-step |
| [architecture-evolution.md](./architecture-evolution.md) | v1 subprocess → observability → load test → warm analyzer |
| [future-state-architecture.md](./future-state-architecture.md) | Target platform shape |

## Diagrams

PNG exports (when added): [diagrams/](./diagrams/)

## Decisions

Architecture Decision Records: [adrs/](./adrs/)

Featured: [ADR-004 — long-running analyzer](./adrs/ADR-004-long-running-analyzer.md) (outcome of [latency investigation](../investigations/latency-investigation/)).

## Supplemental (archive)

Extended platform-thinking and component-level notes: [../archive/architecture-supplemental/](../archive/architecture-supplemental/)

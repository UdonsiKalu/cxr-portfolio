# Architecture

System design for CXR (Claim eXamination & Reasoning) — how components connect, how requests flow, and why key decisions were made.

<!-- portfolio -->

## Core documents

- [c4-context.md](c4-context.md) — system context (C4 L1)
- [c4-container.md](c4-container.md) — containers and ports (C4 L2)
- [request-flow.md](request-flow.md) — analyze path step-by-step
- [architecture-evolution.md](architecture-evolution.md) — v1 subprocess → observability → load test → warm analyzer
- [future-state-architecture.md](future-state-architecture.md) — target platform shape

## Diagrams

PNG exports (when added): [diagrams/README.md](diagrams/README.md)

## Decisions

Architecture Decision Records: [adrs/ADR-004-long-running-analyzer.md](adrs/ADR-004-long-running-analyzer.md) (featured; more in `adrs/`)

Featured outcome: [latency investigation](../investigations/latency-investigation/README.md)

## Supplemental (archive)

Extended platform-thinking and component-level notes: [../archive/architecture-supplemental/c4-component.md](../archive/architecture-supplemental/c4-component.md)

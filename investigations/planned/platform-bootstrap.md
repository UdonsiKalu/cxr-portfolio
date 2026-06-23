# PLATFORM-001 — Platform bootstrap

**Status:** Planned — **Phase 1 step 8** (after OBS-002)

## Question

Can a reviewer bring up the CXR dev stack with one command and reach Claim Studio, analyzer, Jaeger, and Locust?

## Scope

Document reproducible local ops:

- `cxr-dev.sh up` / `down`
- Service map and ports (:8251, :8766, :16686, :8089, :4318)
- Health checks (`curl :8766/health`, `warmed: true`)
- Degraded modes (Qdrant optional, etc.)

See [archive/demo/RUN.md](../../archive/demo/RUN.md) as source material.

## Competencies

Docker, environment management, service orchestration, dependency wiring, reproducibility — without Kubernetes.

## Related architecture

Evolution subprocess → warm analyzer: [latency investigation](../../latency-investigation/), [ADR-004](../../archive/decisions/adrs/ADR-004-long-running-analyzer.md).

When written, promote to `platform-bootstrap/` folder at investigations root.

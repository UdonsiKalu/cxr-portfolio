# Run CXR locally (technical reviewers)

This portfolio documents an implementation that lives across a **staging monorepo** today. To run the same stack:

## Prerequisites

- Linux or WSL2 with Docker (Docker Desktop OK)
- Node.js 20+, Python 3.12+ with CXR venv (`faiss_gpu1`)
- SQL Server + optional Qdrant reachable (or accept WARN and degraded retrieval)
- Clone or access:
  - `cxr-ops-lab` (observe compose + `cxr-dev.sh`)
  - `cxr-ui-prune-rehearsal/cxr-ui`
  - `cxrlabs-dev/claim_analysis_tools`

## Fast path (~5 minutes)

```bash
# 1. Observe + apps + Locust
~/staging/cxr-dev.sh up

# 2. Open
#    Claim Studio  http://127.0.0.1:8251/claim-studio
#    Jaeger        http://127.0.0.1:16686
#    Locust        http://127.0.0.1:8089

# 3. Submit a claim (UI) or swarm Locust (3–5 users)

# 4. Jaeger → cxr-ui-rehearsal → POST /api/claim-studio/analyze
```

## Sample claim JSON

[sample-data/claims.json](./sample-data/claims.json) — synthetic CMS-style claim for API experiments.

## Walkthroughs

- [Submit claim](./walkthrough/submit-claim.md)
- [Trace a request in Jaeger](./walkthrough/trace-request.md)
- [Investigate latency](./walkthrough/investigate-latency.md)

## Stop

```bash
~/staging/cxr-dev.sh down
```

## Future: single-repo demo

Goal: publish companion repos so `git clone` + `docker compose up` runs a minimal public demo without the full staging tree. This portfolio will link them when available.

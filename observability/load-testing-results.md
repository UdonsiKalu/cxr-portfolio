# Load testing results (Locust)

## Setup

| Setting | Value |
|---------|-------|
| Tool | Locust (`cxr-ops-lab/load/locust`) |
| Target host | `http://127.0.0.1:8251` (`CXR_LOAD_URL`) |
| UI | `http://127.0.0.1:8089` |
| Observe | Jaeger `:16686` during runs |

Start load UI: `cxr up` (includes Locust) or `cxr-ops-lab/scripts/22-load-locust.sh`.

## Scenarios exercised

- Claim Studio user flows hitting **POST /api/claim-studio/analyze**
- Mixed with GET navigation (creates many short traces—filter Jaeger by POST)

## Results summary

| Configuration | Approx. POST p95 | Notes |
|---------------|------------------|-------|
| Subprocess analyzer per request | **10–12s** | Dominated by import + init |
| Warm analyzer (`ANALYZER_URL` → :8766) | **1.6–3s** | Steady-state after boot |
| Analyzer cold start (once) | **~7s** | `analyzer_service.startup` trace only |

## How to read Locust with Jaeger

1. Start swarm (3–5 users, spawn rate 1/s to start).
2. In Jaeger: Service `cxr-ui-rehearsal`, Operation `POST /api/claim-studio/analyze`, Last 15 minutes.
3. Pick a slow trace; confirm time is in Node fetch to **8766** or legacy subprocess—not “mystery network.”

## Evidence

- Jaeger search scatter: [screenshots/SW11-jaeger-search-2026-05-30.png](./screenshots/SW11-jaeger-search-2026-05-30.png)
- POST waterfall (subprocess era, ~11s): [screenshots/SW11-jaeger-waterfall-post-analyze-2026-05-30.png](./screenshots/SW11-jaeger-waterfall-post-analyze-2026-05-30.png)

## Honest limits

- Tests ran on **local dev** hardware (Docker Desktop, GPU/CPU variance).
- Not a published SLO or capacity baseline—an **engineering investigation**, not production sign-off.

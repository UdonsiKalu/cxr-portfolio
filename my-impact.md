# My impact on CXR

## The problem

Claim Studio’s **POST /api/claim-studio/analyze** felt “broken slow” under load testing: **~10–12 seconds** per request on Locust, while kernel spans inside Python often showed only **~1–2 seconds** of “real” work. Without tracing, that gap looks like a mystery. With tracing, it becomes an engineering problem you can fix.

## What I delivered

### 1. Made latency measurable (OpenTelemetry + Jaeger)

- Instrumented the **Next.js** analyze route and a **long-lived Python analyzer** on port **8766**.
- Wired **OTLP** (port **4318**) through an OpenTelemetry Collector into **Jaeger** (port **16686**).
- Produced **~21 nested spans** per warm analyze, including `context_builder`, `claim_analysis`, `retrieval`, and import spans on analyzer startup.

**Evidence:** [observability/screenshots/](./observability/screenshots/) · [latency investigation](./observability/latency-investigation.md)

### 2. Found the real bottleneck (investigation, not guessing)

| Phase | Dominant cost | Finding |
|-------|----------------|---------|
| Subprocess-per-request | **~7–8s** `python.module_import` + **corrector.initialize** | New Python process per HTTP request re-loaded torch, embeddings, SQL, Qdrant |
| Kernel-only view | **~1.5s** `context_builder` | Analyze logic was fast once the runtime was warm |
| After fix | **~1.6–3s** warm POST | Long-lived **FastAPI analyzer** + `ANALYZER_URL` from Next.js |

**Evidence:** [INC-003 postmortem](./reliability/incidents/INC-003-python-import-bottleneck/postmortem.md) · [ADR-004](./adrs/ADR-004-long-running-analyzer.md)

### 3. Load-tested with intent (Locust)

- Ran Locust against **:8251** (Claim Studio dev UI) with **`CXR_LOAD_URL`** targeting the analyze API.
- Correlated Locust p95 with Jaeger traces (not just CPU graphs).
- Integrated Locust into the **one-command dev stack** (`cxr up`).

**Evidence:** [load testing results](./observability/load-testing-results.md)

### 4. Operability for humans (including future me)

- **`cxr up` / `cxr down`** — Jaeger + warm analyzer + rehearsal UI + Locust without memorizing fifteen commands.
- Runbooks for **slow API**, **no traces**, **restart stack**.
- Bootcamp lab index (Kafka, ELK, Redis, …) kept **optional** so daily dev stays light.

**Evidence:** [operations/restart-stack.md](./operations/restart-stack.md)

## Metrics that matter (local dev, reproducible)

| Metric | Before | After |
|--------|--------|-------|
| Warm **POST /analyze** (HTTP to analyzer) | ~10–12s (subprocess path) | **~1.6–3s** |
| Jaeger spans per warm POST | unclear / subprocess blind spot | **~21** linked spans |
| Analyzer startup (imports) | paid on **every** request | **~7s once** per analyzer boot (`analyzer_service.startup`) |

## Why this is different from “skills on a CV”

A skills list says *OpenTelemetry*. This repo shows:

- **Where** spans were added (Node route, FastAPI lifespan, kernel stages).
- **Why** a minimal trace profile was rejected (worse UX, fewer useful spans).
- **How** load tests and traces were read together to justify a **warm worker** architecture.

That is implementation credibility.

## What’s next (honest backlog)

- Formal SLOs and error budgets (documented when measured, not invented).
- Chaos experiments on Qdrant/Ollama (planned; see reliability section).
- Public companion repos linked from this portfolio for a single-clone demo.

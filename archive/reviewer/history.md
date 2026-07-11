# CXR development history (curated)

A **single-page arc** of how the CXR engineering program evolved. For dated detail and mistakes, see [CHANGELOG.md](../CHANGELOG.md). For evidence, follow links into [investigations/](../investigations/README.md).

**Scope:** Local lab, synthetic data — not production deployment history.

---

## Arc 1 — Latency: from “10s analyze” to warm service

| When | What happened |
|------|----------------|
| **Problem** | POST `/api/claim-studio/analyze` averaged **~10–12s** under Locust; unclear where time went. |
| **Method** | OpenTelemetry + Jaeger on UI and Python; Locust at `:8251`. |
| **Finding** | Subprocess-per-request paid **~7–8s** import/initialize on every call; kernel work was ~1–2s once warm. |
| **Decision** | Long-running FastAPI analyzer on **:8766** ([ADR-004](../architecture/adrs/ADR-004-long-running-analyzer.md)). |
| **Outcome** | Locust p95 **~1.5s**; warm Jaeger traces **~154–708ms**. |

**Read:** [latency investigation](../investigations/latency-investigation/) · [postmortem: python import](../old-investigations/postmortems/python-import-bottleneck.md)

---

## Arc 2 — Capacity: single process → Kubernetes saturation

| When | What happened |
|------|----------------|
| **LOAD-001** | One warm analyzer: **15 users**, 0% failures, p95 ~1.6s — headroom exists. |
| **LOAD-002** | Single-process saturation: knee ~**30–35** users; tail latency runaway to ~225 users, **~15–16 RPS** ceiling. |
| **LOAD-003** | K8 + HPA on Docker Desktop: **200 users**, ~**50 RPS**, HPA to caps; node CPU **not** saturated. |
| **OBS-001** | Deep observe: **p95 ~9s** at 200 users, pending pods, cold start **~15–17s**, `context_builder` **3–6s**. |
| **PERF-003** | Context-builder cache → image `perf003`; micro-load validation passed. |
| **Jun 18 regression** | Post-fix ramp still unstable: collapses, **~132 failures/s** — UI/HPA/scheduling, not host CPU. |
| **GATE-002 (Jun 19)** | Automated 12-recipe **KEDA + Helm grid**; **11/12 pass**; winner **candidate 4** (~**102 RPS**, p95 **~820ms**, 0 failures @ 200). Study: [GATE-002 doc](../investigations/kubernetes-analyzer-saturation/studies/GATE-002-keda-helm-grid-study.md). |

**Read:** [kubernetes-analyzer-saturation](../investigations/kubernetes-analyzer-saturation/) · [GATE-002 KEDA grid study](GATE-002-keda-helm-grid-study.md) · [OBS-001 run](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) · [tuner winner](../investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json) · [failures: c1](../failures/README.md)

---

## Arc 3 — Reliability: dependencies, chaos, observability

| When | What happened |
|------|----------------|
| **Trace propagation** | `traceparent` from UI → analyzer (OTEL-001). |
| **Qdrant outage** | Analyzer degrades gracefully when vector DB down (DEP-001). |
| **Kill analyzer under traffic** | Explicit 500s and recovery window (CHAOS-001). |
| **Missing spans / Jaeger UX** | Trace profile trade-offs documented. |
| **SLO framework** | [reliability/SLO.md](../reliability/SLO.md) — gates vs production tiers. |

**Read:** [investigations index](investigations/README.md) · [SLO.md](../reliability/SLO.md)

---

## Arc 4 — Platform: CI, GitOps, automation

| When | What happened |
|------|----------------|
| **CI-001** | GitHub Actions on `cxr-ui-rehearsal`. |
| **K8-001** | Helm deploy to local cluster. |
| **Argo / GitOps** | Automated sync conflict with local tuning — documented, mitigated. |
| **GATE-001 / GATE-002** | Headless load gates + Helm tuner in `cxr-ops-lab` (linked from LOAD-003). |

**Read:** [operations/](../operations/README.md) · [CHANGELOG — Operations](../CHANGELOG.md)

---

## What we explicitly do not claim

- Production SLO compliance (lab gates only, except proposed targets in SLO.md)  
- Multi-region / HA deployment  
- Real PHI or payer production integrations  
- All “planned” investigations in `investigations/planned/` — backlog, not evidence  

---

## Metrics snapshot (reviewer cheat sheet)

| Metric | Before (subprocess era) | After warm analyzer | After GATE-002 winner @200 users |
|--------|-------------------------|---------------------|----------------------------------|
| Locust p95 (analyze) | ~10–12s | ~1.5s (low load) | ~820ms (saturation gate) |
| Failures @ peak load | — | — | **0/s** (11/12 recipes) |
| Dominant bottleneck | Python import / cold process | context_builder (later optimized) | UI proxy + autoscaling shape (node CPU &lt;11%) |

---

## Next chapter (open)

- Context-builder production perf on saturation path  
- Analyzer replica metrics in observe stack (Grafana gap)  
- Promote GATE-002 winner to git-managed Helm values + Argo  
- Lightweight mixed traffic profile vs analyze-only saturation  

See [CHANGELOG](../CHANGELOG.md) for dated entries as work lands.

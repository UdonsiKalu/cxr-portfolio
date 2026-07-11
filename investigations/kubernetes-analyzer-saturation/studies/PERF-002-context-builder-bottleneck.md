# PERF-002 — Context builder bottleneck isolation

| | |
|---|---|
| **Status** | **Resolved** (span tree 2026-06; PERF-003 verify 2026-06-18) |
| **GitHub issue** | [cxr-portfolio#6](https://github.com/UdonsiKalu/cxr-portfolio/issues/6) |
| **Builds on** | [OBS-001 / LOAD-003](../evidence/load-observe/RUN-2026-06-17.md) |
| **Follow-on optimize** | PERF-003 — TTL cache + financial path (`cxr-analyzer:perf003`) |
| **Code** | `cxr_kernel_v3_2_integrated.py` → `ContextCollector.gather_full_context` |
| **Earlier planned stub** | [planned/context-builder-optimization.md](../../planned/context-builder-optimization.md) |

---

## Answer (read this first)

Under LOAD-003, warm POSTs spent **3.8–6.2s** in a single opaque Jaeger span: **`context_builder`**. Node CPU was only ~15%. LLM and retrieval were microseconds in those traces.

**PERF-002** broke that black box into stage spans (`context.1_patient` … `context.7_policy` + SQL children) so we could measure before optimizing.

**PERF-003** then cut redundant SQL with an in-process TTL cache and a financial-path fix. At **50 users** (2026-06-18): `context_builder` p50 **~4.5ms**, cache hits **12/12**, POST p95 **~110ms**.

**What this did not fix:** full **0→200** ramp stability. After PERF-003 the big ramp still misbehaved (see [failures Arc 3](../../../failures/README.md)); later [PERF-009](PERF-009-jaeger-tail-latency.md) showed most remaining p95 tail is **UI→analyzer wait**, with context builder secondary.

---

## Problem (from OBS-001)

| Signal | Observation |
|--------|-------------|
| Locust / Grafana p95 | Climbed toward ~9s at 200 users |
| Node CPU | ~15% — not host saturation |
| Warm POST traces | **`context_builder` 3.8–6.2s**; ~750ms queue wait on slow ones |
| Not dominant | LLM `send`, retrieval |

Evidence: [RUN-2026-06-17](../evidence/load-observe/RUN-2026-06-17.md) · screenshots in [load-observe](../evidence/load-observe/) (e.g. `jaeger-post-3p9s-context-builder.png`, `jaeger-post-7s-context-builder.png`, `jaeger-context-builder-3p8s-20260617.png`).

---

## Method (PERF-002)

**Goal:** Measure first — do not optimize until top sub-spans are identified.

Requires `CXR_TRACE_PROFILE=detailed` (default in K8 analyzer Helm values).

```
context_builder
├── context.1_patient
├── context.2_provider
│   └── context.2_provider.sql
├── context.3_payer
├── context.4_temporal
├── context.5_financial
│   └── context.5_financial.sql
├── context.6_relationship
├── context.7_policy
│   └── context.7_policy.sql
└── context.aggregate_scores
```

**How we verified:** observe stack (`23-k8-load-observe-up.sh`) + LOAD-003 ramp → Jaeger → expand `context_builder` on slow vs fast POSTs (same compare discipline as OBS-001).

**Out of scope for this card:** HPA / cold-start; sibling spans `archetype_reasoning`, `retrieval`, `llm_inference`.

---

## Fix (PERF-003)

| Item | Detail |
|------|--------|
| Branch / tag | `perf-003-context-builder-optimize` / baseline tag `perf-002-baseline` |
| Image | `cxr-analyzer:perf003` |
| Env | `CXR_CONTEXT_CACHE_TTL_S=900` (set `0` to disable) |

What changed:

1. Financial path — read `amount` / dict `HCPCS_CD_*` / `cpt` for normalized API claims  
2. Provider + financial SQL — TTL in-process cache (`context.cache_hit` on spans)  
3. Provider query — prefer `CXR_Claim_Context.provider_id` before legacy `LIKE` scan  

**Verify (2026-06-18, 50 users):** 0 failures; POST p50 ~56ms / p95 ~110ms; Jaeger `context_builder` p50 ~4.5ms; cache hits 12/12. Logged in [CHANGELOG](../../../CHANGELOG.md).

---

## Residual / next

| Topic | Where |
|-------|--------|
| 200-user ramp still unstable after cache | [failures Arc 3](../../../failures/README.md) · GATE-002 / PERF-008 |
| p95 mostly HTTP wait, not builder | [PERF-009](PERF-009-jaeger-tail-latency.md) |
| SQL busy under concurrency on shared connection | [OBS-003](OBS-003-shared-sql-connection.md) |

Any further 200-user stage re-profile should be a **new** issue — this study is closed.

---

## Related

- [planned stub (historical)](../../planned/context-builder-optimization.md)  
- [failures Arc 2](../../../failures/README.md) — OBS-001 narrative  
- Issue [#6](https://github.com/UdonsiKalu/cxr-portfolio/issues/6)

# PERF-002 — Context builder bottleneck isolation

| | |
|---|---|
| **Status** | PERF-002 spans done; **PERF-003** optimize on branch `perf-003-context-builder-optimize` |
| **ID** | PERF-002 |
| **Builds on** | [LOAD-003 OBS-001](../kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) |
| **Code** | `cxr_kernel_v3_2_integrated.py` → `ContextCollector.gather_full_context` |

## Background

LOAD-003 showed `context_builder` at **3.8–6.2s** under load while node CPU stayed ~15%. Jaeger showed retrieval/LLM at µs. This span was a black box.

## Goal

Break down `context_builder` in Jaeger. **Measure first — do not optimize** until top sub-spans are identified.

## Span tree (detailed profile)

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

## How to verify

1. Rebuild/restart analyzer image with instrumented kernel.
2. `./scripts/23-k8-load-observe-up.sh` + LOAD-003 ramp.
3. Jaeger → `cxr-ui-k8` → `POST` → open slow trace → expand `context_builder`.
4. Compare fast (~4s) vs slow (~7s) traces (same method as OBS-001 Pair 2).

## Success criteria

- [ ] Identify which of the 7 types (or SQL sub-spans) consumes most of 3.8–6.2s under load
- [ ] Top 3 slowest sub-spans documented with screenshots
- [ ] Evidence doc: `evidence/load-observe/PERF-002-YYYY-MM-DD.md`
- [ ] Optimization proposal tied to measured dominant span only

## Out of scope

- HPA / cold-start (LOAD-003 scaling)
- `archetype_reasoning`, `retrieval`, `llm_inference` (sibling spans)

## PERF-003 changes (provider cache + financial path fix)

**Repo:** `cxrlabs-dev/claim_analysis_tools` (cxr-saas on GitHub)

| Item | Detail |
|------|--------|
| **Restore tag** | `perf-002-baseline` — spans only, before SQL/cache optimize |
| **Work branch** | `perf-003-context-builder-optimize` |
| **Env** | `CXR_CONTEXT_CACHE_TTL_S=900` (default 15m); set `0` to disable cache |

### Roll back one file

```bash
cd ~/staging/cxrlabs-dev/claim_analysis_tools
git checkout perf-002-baseline -- archetype_catalog_v3_1_master/cxr_kernel_v3_2_integrated.py
# restart analyzer / rebuild K8 image
```

### Roll back entire branch

```bash
git checkout feature/cxr-ui-analyzer-auditor-path-resolution   # or your main line
git branch -D perf-003-context-builder-optimize   # optional
```

### What PERF-003 does

1. **Financial** — read `amount` / dict `HCPCS_CD_*` / `cpt` (normalized API claims)
2. **Provider + financial SQL** — TTL in-process cache (`context.cache_hit` on spans)
3. **Provider query** — try `CXR_Claim_Context.provider_id` before legacy `LIKE` scan

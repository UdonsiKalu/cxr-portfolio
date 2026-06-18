# PERF-002 — Context builder bottleneck isolation

| | |
|---|---|
| **Status** | Instrumentation landed (2026-06-17); profiling run pending |
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

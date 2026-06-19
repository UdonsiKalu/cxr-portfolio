# LOAD / PERF changelog

Living record of **problems observed** during LOAD-003 and related performance work, and **resolutions implemented or planned**. Newest entries first.

| | |
|---|---|
| **Scope** | K8 LOAD-003 · OBS-001 · PERF-002/003 · Helm/Argo · scaling policy |
| **Evidence** | `results/load-*.csv` · `evidence/load-observe/` · Grafana `cxr-hpa-load-003` |
| **Ops repo** | `cxr-ops-lab` (Helm, scripts, observe stack) |
| **Code repo** | `cxrlabs-dev/claim_analysis_tools` (analyzer kernel, PERF-003 branch) |

### How to add an entry

1. Append a dated block under **Changelog** (newest on top).
2. Link CSV, screenshot, or `RUN-*.md` — do not paste long tables here.
3. Mark status: **Resolved** · **Mitigated** · **Open** · **Planned**.

---

## Changelog

### 2026-06-18 — GATE-001 / SCALE-001 / SCALE-003 automation (implemented)

| | |
|---|---|
| **Problem** | Manual Grafana/Helm tweaking does not scale; need industry-standard **performance regression gate** and **dynamic scaling signals**. |
| **Resolution** | **Implemented** on branch `feature/load-perf-automation` in `cxr-ops-lab` + `cxr-portfolio`. |
| **Phase A** | `scripts/k8-load-gate.sh` — headless stages 50/100/150/200, `scripts/lib/load_gate_score.py`; Prometheus rules `cxr_load_stable`, `cxr_replica_collapse`, `cxr_load_p95_pressure`; CI `workflow_dispatch` `.github/workflows/k8-load-gate.yml` (self-hosted). |
| **Phase B** | KEDA `ScaledObject` (CPU + `cxr_locust_p95_ms`); `minReplicas: 2`; PDB; `scripts/11-keda-install.sh`. |
| **Phase C** | VPA `updateMode: Off` + `scripts/12-vpa-install.sh`; optional Pyroscope `scripts/24-pyroscope-up.sh` (profile `pyroscope`). |
| **Docs** | `cxr-ops-lab/docs/K8-LOAD-GATE.md` |
| **Revert** | `git checkout main` (ops-lab) / `git checkout master` (portfolio) |

---

### 2026-06-18 — Post-fix ramp still unstable at 200 users (mitigated, open)

| | |
|---|---|
| **Problem** | After PERF-003 + `maxReplicas: 8`, full **0→200** ramp still shows sawtooth RPS, **18× analyzer replica collapses** (8→1), and **~132 failures/s** at peak. |
| **Symptoms** | Peak **~135 RPS** (better than pre-fix ~50); p95 **~5–6s** at load; UI HPA **~184%/80%**, **5/5** replicas; periodic RPS valleys aligned with HPA scale steps. |
| **Root cause** | **Capacity ceiling** on single Docker Desktop node + **scale churn** (cold starts, rollouts) + **UI tier bottleneck**; CPU-only HPA is a poor signal after PERF-003 lowers per-request CPU. |
| **Resolution** | **Mitigated** throughput and memory pressure via prior fixes; **Open:** `minReplicas`, PDB, HPA/KEDA on **p95/failures**, UI scale headroom, automated **load gate** (see Planned). |
| **Artifacts** | `results/load-20260618-064836.csv` · Grafana session ~06:50–07:34 |

---

### 2026-06-18 — Argo CD reverted local Helm tuning

| | |
|---|---|
| **Problem** | `helm upgrade` with `maxReplicas: 8` and `image: perf003` was **overwritten within minutes** — HPA back to **maxReplicas 20**, pods on `cxr-analyzer:local`. |
| **Symptoms** | Verification load test showed replicas **max 20**, local image RS returning mid-run. |
| **Root cause** | Argo CD **automated sync + selfHeal** from GitHub `main` (still had `maxReplicas: 20`, `tag: local`). |
| **Resolution** | **Resolved (cluster):** `kubectl patch application` with helm parameters `image.tag=perf003`, `autoscaling.maxReplicas=8` (analyzer), `5` (UI). **Planned:** push `cxr-ops-lab/helm/*/values.yaml` to `main` so Git and cluster agree. |
| **Artifacts** | `cxr-ops-lab/helm/cxr-analyzer/values.yaml` · `k8s/argocd/application-*.yaml` (commented override notes) |

---

### 2026-06-18 — HPA thrashing at maxReplicas 20 (memory-bound)

| | |
|---|---|
| **Problem** | Analyzer HPA pinned at **20/20** with **6 pending** pods; recurring **20→1 replica collapses**; HPA CPU spikes **~360%** while **node CPU ~8–15%**. |
| **Symptoms** | Locust failures at collapses; p95 **~9s** (Jun 17) / **~4–9s** (Jun 18 AM); `FailedScheduling: Insufficient memory`; liveness/readiness timeouts killing pods. |
| **Root cause** | **20 × 2Gi request** (6Gi limit) exceeds practical single-node scheduling; HPA keeps requesting pods the node cannot place; surviving pods overloaded → probe failures → more churn. |
| **Resolution** | **Resolved:** analyzer `maxReplicas: **8**`, UI `maxReplicas: **5**` (Helm + Argo parameters). |
| **Artifacts** | `results/load-20260618-060419.csv` · `results/load-20260617-153750.csv` |

---

### 2026-06-18 — PERF-003 verification (50 users, 4 min)

| | |
|---|---|
| **Problem** | Need confidence fixes work before full LOAD-003 rerun. |
| **Symptoms** | N/A — acceptance run. |
| **Resolution** | **Resolved:** headless Locust **50 users** — **0 failures**, POST **p50 56ms / p95 110ms**, analyzer replicas **≤4**, no collapses, Jaeger `context_builder` **p50 4.5ms**, **12/12 cache hits**. |
| **Artifacts** | Agent-run verification; cluster state `cxr-analyzer:perf003`, HPA max **8** |

---

### 2026-06-17 — OBS-001: latency without node saturation

| | |
|---|---|
| **Problem** | **p95 ~9s** and unstable RPS at **200 users** while **node CPU ~15%** — looks like “cluster has headroom” but UX is slow. |
| **Symptoms** | HPA **1→~18** with thrashing; **pending pods**; Grafana four-panel problem summary. |
| **Root cause** | (1) **~15–17s cold start** per new analyzer pod. (2) **`context_builder` 3.8–6.2s** on warm POSTs. (3) **~750ms queue wait** before `context_builder`. LLM/retrieval **not** dominant in sampled traces. |
| **Resolution** | **Documented** in OBS-001; led to PERF-002 (measure) and PERF-003 (optimize). Scaling/cold-start items **open**. |
| **Artifacts** | [evidence/load-observe/RUN-2026-06-17.md](./evidence/load-observe/RUN-2026-06-17.md) · `grafana-load-003-problem-summary.png` |

---

### 2026-06-17 — CSV has no `context_builder` column

| | |
|---|---|
| **Problem** | Load metrics CSV cannot answer “how long is context_builder?” |
| **Symptoms** | Users expect `context_builder` ms in `load-*.csv`; only Locust **end-to-end** p50/p95 + HPA columns exist. |
| **Root cause** | `collect_load_metrics.py` polls Locust + `kubectl`; span duration lives in **Jaeger** only. |
| **Resolution** | **Documented** — use Jaeger during/after run, or future Prometheus histogram from OTLP. **Planned:** optional span-duration exporter. |
| **Artifacts** | `cxr-ops-lab/scripts/lib/load_metrics_poll.py` FIELDNAMES |

---

### PERF-003 — Context builder cache + financial path (implemented)

| | |
|---|---|
| **Problem** | `context_builder` dominated warm POST latency; redundant SQL on every request. |
| **Symptoms** | Jaeger: **3.8–6.2s** in `context_builder`; node CPU still low. |
| **Root cause** | Uncached provider/financial SQL; financial reader missed normalized claim fields. |
| **Resolution** | **Resolved (code):** `_TimedContextCache` (TTL `CXR_CONTEXT_CACHE_TTL_S`, default 900s); provider `provider_id` path; financial `_claim_amount()` / `_primary_procedure_code()`; Jaeger `context.cache_hit`. **Branch:** `perf-003-context-builder-optimize` · **Image:** `cxr-analyzer:perf003` · **Rollback tag:** `perf-002-baseline`. |
| **Artifacts** | [planned/context-builder-optimization.md](../planned/context-builder-optimization.md) · `cxr_kernel_v3_2_integrated.py` |

---

### PERF-002 — Context builder span breakdown (implemented)

| | |
|---|---|
| **Problem** | `context_builder` was a single opaque Jaeger span. |
| **Resolution** | **Resolved:** nested spans `context.1_patient` … `context.7_policy`, SQL sub-spans, `context.aggregate_scores`; requires `CXR_TRACE_PROFILE=detailed`. |
| **Artifacts** | [planned/context-builder-optimization.md](../planned/context-builder-optimization.md) |

---

### 2026-06-08 — LOAD-003b: maxReplicas 20 experiment (regression)

| | |
|---|---|
| **Problem** | Raising GitOps caps to **20/20** destabilized an otherwise good run. |
| **Symptoms** | HPA thrashing, pending pods, p95 spikes vs stable **8/5** cap run. |
| **Resolution** | **Resolved (lesson):** **8/5** caps appropriate for Docker Desktop lab; **20** is not “more capacity” on one node — it increases **pending + churn**. |
| **Artifacts** | `results/load-20260608-182451.csv` vs `load-20260608-125236.csv` |

---

### 2026-06-07 / 08 — LOAD-003 baseline (stable reference)

| | |
|---|---|
| **Problem** | Does K8 HPA beat single-process LOAD-002 (~15–16 RPS)? |
| **Resolution** | **Resolved:** Yes — **~20–50 RPS** depending on caps/node; analyzer **4–8**, UI **3–5** at saturation; **0 fail/s** on best runs. |
| **Artifacts** | [README.md](./README.md) · `results/load-20260608-125236.csv` · screenshots/ |

---

### Ops — Stale Docker image tag on rollout

| | |
|---|---|
| **Problem** | Rebuild `cxr-analyzer:local` but K8 pods unchanged — no nested spans / cache. |
| **Root cause** | Docker Desktop K8 reuses **same tag digest**; `imagePullPolicy: IfNotPresent` skips pull. |
| **Resolution** | **Resolved:** use explicit tag **`cxr-analyzer:perf003`** (or pin digest) in Helm/Argo; `kubectl set image` + rollout. |
| **Artifacts** | Helm `image.tag` · deployment verify |

---

### Grafana — HPA panel dual-axis confusion

| | |
|---|---|
| **Problem** | “**125 replicas**” or “replicas dropped to 0” misread from chart. |
| **Root cause** | **CPU %** (left axis, 0–400%) overlaid with **replica count** (right axis, 0–8) in `cxr-hpa-load-003`. |
| **Resolution** | **Documented** — read orange/red on **right** axis only; CSV `analyzer_replicas` column for ground truth. **Planned:** split panels or fix target % legend (stale 200% line). |
| **Artifacts** | `cxr-ops-lab/observe/grafana/provisioning/dashboards/cxr-hpa-load-003.json` |

---

## Planned (not yet implemented)

| ID | Problem addressed | Approach | Status |
|----|-------------------|----------|--------|
| **GATE-001** | Manual Grafana/Helm tweaking | `k8-load-gate.sh` — headless Locust stages, fail on collapses / `failures/s` / p95 | **Implemented** — see `cxr-ops-lab/docs/K8-LOAD-GATE.md` |
| **SCALE-001** | CPU-only HPA after PERF-003 | KEDA on **p95 / CPU** from `cxr-load-exporter` | **Implemented** — `autoscaling.keda.enabled` |
| **SCALE-002** | 8→1 replica cliffs | `minReplicas: 2`, PDB, readiness waits for `warmed=true` | **Partial** — minReplicas + PDB done; warm readiness open |
| **SCALE-003** | UI bottleneck at peak load | UI `maxReplicas` / scale signal on proxy latency | Open |
| **GIT-001** | Argo vs local Helm drift | Push `values.yaml` + Argo parameters to `main` | Open |
| **OBS-002** | `context_builder` not in CSV | OTLP histogram → Prometheus (optional) | Open |
| **PROF-001** | Code hotspots after PERF-003 | Pyroscope optional profile — **profiling only** | **Implemented** (optional `24-pyroscope-up.sh`) |
| **VPA-001** | Wrong CPU/memory requests | VPA `updateMode: Off` → tune Helm from recommendations | **Implemented** — `12-vpa-install.sh` |

---

## Quick reference — current stable-ish config (2026-06-18)

| Setting | Value |
|---------|-------|
| **Branch** | `feature/load-perf-automation` (revert: `main` / `master`) |
| Analyzer image | `cxr-analyzer:perf003` |
| Analyzer `minReplicas` | **2** |
| Analyzer `maxReplicas` | **8** |
| Scaling | **KEDA** (CPU + `cxr_locust_p95_ms`) when `autoscaling.keda.enabled` |
| VPA | `updateMode: Off` (recommendations only) |
| Load gate | `./scripts/k8-load-gate.sh` |
| Trace profile | `CXR_TRACE_PROFILE=detailed` |
| Context cache TTL | `CXR_CONTEXT_CACHE_TTL_S=900` |
| Argo overrides | `image.tag=perf003`, `maxReplicas=8`, `minReplicas=2` (cluster patch until Git push) |

**Known knee:** ~**100–120 users** strict gate; use `--soft-200` for 200-user report-only.

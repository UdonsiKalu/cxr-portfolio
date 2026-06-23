# CXR Portfolio — Changelog

Auditable history of **problems, decisions, mistakes, and progress** across the CXR engineering program. Written for recruiters, technical interviewers, and future-you—not as release notes, but as an honest engineering journal.

| | |
|---|---|
| **Repos** | This portfolio (evidence) · `cxr-ops-lab` (deploy/observe) · `cxrlabs-dev/claim_analysis_tools` (analyzer) · `cxr-ui-rehearsal` (UI) |
| **Environment** | Local lab, synthetic data — not production |
| **Convention** | Newest entries first under each section |

---

## How to read this

Each entry follows the same shape where possible:

| Field | Meaning |
|-------|---------|
| **Area** | `Investigations` · `Architecture` · `Operations` · `Demo` · `Archive` · `Platform` |
| **Problem** | What broke or what we needed to learn |
| **Outcome** | **Resolved** · **Mitigated** · **Open** · **Documented** · **Planned** |
| **Artifacts** | Links to evidence (CSV, ADR, screenshot, run doc) |

**Status labels:** Resolved · Mitigated / partial · Open · Documented only

---

## Index (by area)

| Area | What belongs here |
|------|-------------------|
| [Investigations](#investigations) | Load tests, latency, chaos, outages, PERF work |
| [Architecture](#architecture) | ADRs, service design, observability model, evolution |
| [Operations](#operations) | K8, Helm, Argo, CI/CD, deploy runbooks |
| [Demo](#demo) | Walkthroughs, stakeholder demos |
| [Archive](#archive) | Superseded docs, meta, navigation |
| [Platform](#platform) | Portfolio structure, lab workspace, tooling |

---

## Investigations

Performance, reliability, and observability studies. Deep dives live in each study folder; this log is the cross-study narrative.

### Performance & load — LOAD-003 arc (2026-06)

#### 2026-06-23 — Portfolio layout: DevOps-first directories (documented)

| | |
|---|---|
| **Problem** | PERF-009 touched five+ top-level trees (`docs/`, `failures/`, `evidence/`, `CHANGELOG`, workflow) — too many places per study. |
| **Outcome** | **Documented:** Study write-ups co-located under `investigations/kubernetes-analyzer-saturation/studies/`; `operations/GITHUB-WORKFLOW.md`; `demo/` and reviewer indexes → `archive/`; C4 docs → `archive/architecture-c4/`; keep `architecture/adrs/` only. |
| **Artifacts** | [README.md](README.md) · [studies/README.md](investigations/kubernetes-analyzer-saturation/studies/README.md) |

#### 2026-06-23 — PERF-009 addendum: canonical Jaeger compare pair (documented)

| | |
|---|---|
| **Problem** | PR #31 merged before reviewer walkthrough screenshots were in-repo; medians alone did not show the **pre-handler wait gap** as clearly as a single fast/slow pair. |
| **Finding** | Same load second: fast trace `fd42f1c` **40.7 ms** vs slow `f541546` **824 ms**. Slow trace: `fetch` **818 ms**, `analyze_request` **~57 ms** starting **~652 ms** in → **~649 ms** client wait before handler work. Analyzer stages stay short; OBS-003 SQL errors are inside that short window, not the gap. |
| **Outcome** | **Documented** — visual evidence in PERF-009 § canonical pair; screenshots in `evidence/perf009/`. |
| **Artifacts** | [PERF-009 § visual evidence](investigations/kubernetes-analyzer-saturation/studies/PERF-009-jaeger-tail-latency.md#visual-evidence--canonical-fast-vs-slow-pair-reviewer-walkthrough) · [failures Arc 5](failures/README.md) · follow-up PR after #31 |

#### 2026-06-22 — OBS-003: shared SQL connection busy under concurrent analyze (resolved)

| | |
|---|---|
| **Problem** | Jaeger slow traces showed **2 Errors** on `context.7_policy` / `context.7_policy.sql` during PERF-009 review — `pyodbc.Error: Connection is busy with results for another command`. |
| **Cause** | One **shared** SQL connection per analyzer pod; **4 concurrent** `/analyze` handlers (`MAX_CONCURRENT=4`) issued overlapping cursors via `ContextCollector`. |
| **Outcome** | **Resolved:** `threading.Lock` + `_db_cursor()` in `ContextCollector`; lab image `cxr-analyzer:perf009-sql`. Verified 0 policy span errors in fresh Jaeger window @100 users. |
| **Artifacts** | [PERF-009 § SQL errors](investigations/kubernetes-analyzer-saturation/studies/PERF-009-jaeger-tail-latency.md#jaeger-trace-errors-sql-concurrency) · [failures Arc 5](failures/README.md) · [issue #33](https://github.com/UdonsiKalu/cxr-portfolio/issues/33) · `cxr-saas` / `cxr-ops-lab` PRs |

#### 2026-06-22 — PERF-009 Jaeger tail latency attribution (resolved)

| | |
|---|---|
| **Problem** | PERF-008 rejected inflight KEDA but did not explain **why p95 climbs** (~150 ms → ~800 ms) while p50 stays low. |
| **Method** | Jaeger fast (80–250 ms) vs slow (600–1200 ms) `POST` traces; 3+3 per PERF-008 Experiment A and B helm profiles; replay @200 users (original gate traces not in Jaeger retention). |
| **Outcome** | **Resolved:** Tail dominated by **HTTP/client wait** (UI `fetch` → analyzer, ~+565–617 ms median slow−fast). Confirmed on canonical pair `fd42f1c` (41 ms) vs `f541546` (824 ms): **~649 ms** pre-handler wait, **~57 ms** analyzer work. Analyzer `context_builder`/policy/archetype secondary (+30–40 ms). **B vs A:** same slow-span pattern. |
| **Artifacts** | [PERF-009 doc](investigations/kubernetes-analyzer-saturation/studies/PERF-009-jaeger-tail-latency.md) · [evidence/perf009/](investigations/kubernetes-analyzer-saturation/evidence/perf009/) (JSON + compare screenshots) · `cxr-ops-lab/scripts/perf009-jaeger-attribution.sh` |

#### 2026-06-22 — PERF-008 Experiment B (in-flight/pod KEDA) (mitigated)

| | |
|---|---|
| **Problem** | Does scaling on **analyzer in-flight per pod** beat **Locust E2E p95** for stability and tail latency? |
| **Method** | Same cumulative ramp as A (`analyzer_saturation`, 15→200); KEDA on `sum(inflight)/replicas > 2` + CPU; image `perf008`, lab `MAX_CONCURRENT=4`. |
| **Outcome** | **Mitigated:** Scaled **2→8** replicas but **GATE FAIL @ 200 users** — **115.8 failures/s** (`status 0` connectivity). **Decision:** keep **p95 + CPU** for KEDA; use inflight/wait for diagnosis only. |
| **Artifacts** | [PERF-008 doc](investigations/kubernetes-analyzer-saturation/studies/PERF-008-queue-depth-autoscaling.md) · `cxr-ops-lab/evidence/perf008/exp-b-20260622-034010/` |

#### 2026-06-21 — PERF-008 Experiment A (p95 KEDA) + OBS-002 fix (resolved)

| | |
|---|---|
| **Problem** | OBS-002: Grafana/CSV showed **analyzer_replicas = 0** after KEDA replaced HPA. Need honest A/B: p95 vs backpressure autoscaling signals. |
| **Method** | Instrument analyzer `/metrics` (inflight, queue wait); fix exporter to read Deployment readyReplicas; cumulative gate; Experiment A = KEDA on `cxr_locust_p95_ms`. |
| **Outcome** | **Resolved:** **GATE PASS @ 200** — 101 RPS, p95 **790 ms**, **0 failures/s**, replicas **2→8**. OBS-002 replica truth validated. |
| **Artifacts** | [PERF-008 doc](investigations/kubernetes-analyzer-saturation/studies/PERF-008-queue-depth-autoscaling.md) · `cxr-ops-lab/evidence/perf008/exp-a-20260621-184452/` |

#### 2026-06-19 — GATE-002: first KEDA apply + 12-point Helm grid (11/12 pass) (resolved)

| | |
|---|---|
| **Problem** | CPU-only HPA produced thrash and collapses; manual Grafana tuning was not reproducible. Needed first controlled **KEDA** deployment and a searchable **Helm cap** recipe under OBS-comparable load. |
| **Method** | Install KEDA (`11-keda-install.sh`); replace analyzer HPA with `ScaledObject` (CPU 70% + `cxr_locust_p95_ms` > 2000 ms). **`k8-load-tuner.sh`** grid: 12 candidates (analyzer max 6/8/10 × min 1/2 × UI max 4/5), cumulative ramp 15→200, score via `k8-load-gate.sh`. |
| **Outcome** | **Resolved:** **11/12 passed.** **Winner candidate 4** — analyzer `maxReplicas=8`, `minReplicas=1`, UI `maxReplicas=4`, KEDA p95 2000 ms — **102 RPS**, p95 **~820ms**, **0 failures/s** @ 200. **Only failure:** candidate 1 (UI max=5, min=1) — **116 failures/s**. Lab baseline for PERF-008. |
| **Artifacts** | [GATE-002 KEDA grid study](investigations/kubernetes-analyzer-saturation/studies/GATE-002-keda-helm-grid-study.md) · [tuner-summary-20260619-080505.json](investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json) · [failures Arc 4](failures/README.md) · [SLO.md](reliability/SLO.md) |

#### 2026-06-18 — Post-fix ramp still unstable at 200 users (mitigated)

| | |
|---|---|
| **Problem** | After PERF-003 + `maxReplicas: 8`, full **0→200** ramp still shows sawtooth RPS, **18× analyzer replica collapses** (8→1), **~132 failures/s** at peak. |
| **Symptoms** | Peak **~135 RPS** (vs pre-fix ~50); p95 **~5–6s**; UI HPA **~184%/80%** at **5/5** replicas. |
| **Root cause** | Single-node capacity ceiling + scale churn + UI bottleneck; CPU-only HPA poor signal after PERF-003. |
| **Outcome** | **Mitigated:** Throughput/memory improved; stable 200-user pass still **open**. |
| **Artifacts** | [load-20260618-064836.csv](investigations/kubernetes-analyzer-saturation/results/load-20260618-064836.csv) · [LOAD-003 README](investigations/kubernetes-analyzer-saturation/README.md) |

#### 2026-06-18 — HPA thrashing at maxReplicas 20 (memory-bound) (resolved)

| | |
|---|---|
| **Problem** | Analyzer HPA **20/20**, **6 pending**, recurring **20→1** collapses, HPA CPU **~360%** while node CPU **~8–15%**. |
| **Root cause** | **20 × 2Gi** pod requests exceed Docker Desktop scheduling; probe kills under overload. |
| **Outcome** | **Resolved:** Caps **8** analyzer / **5** UI; memory pressure reduced. |
| **Artifacts** | [load-20260618-060419.csv](investigations/kubernetes-analyzer-saturation/results/load-20260618-060419.csv) |

#### 2026-06-18 — Argo CD reverted local Helm tuning (resolved)

| | |
|---|---|
| **Problem** | Local `helm upgrade` (perf003, maxReplicas 8) overwritten within minutes. |
| **Root cause** | Argo **automated sync + selfHeal** from GitHub `main` with old values. |
| **Outcome** | **Resolved:** Cluster patch via Argo helm parameters; push values to `main` still **open** (GIT-001). |
| **Artifacts** | `cxr-ops-lab/helm/cxr-analyzer/values.yaml` |

#### 2026-06-18 — PERF-003 verification (50 users) (resolved)

| | |
|---|---|
| **Problem** | Validate context-builder optimization before full LOAD-003 rerun. |
| **Outcome** | **Resolved:** **0 failures**; POST p50 **56ms** / p95 **110ms**; Jaeger `context_builder` p50 **4.5ms**, cache hits **12/12**. |
| **Artifacts** | [context-builder-optimization.md](investigations/planned/context-builder-optimization.md) |

#### 2026-06-17 — OBS-001: latency without node saturation (documented)

| | |
|---|---|
| **Problem** | **p95 ~9s** at 200 users while **node CPU ~15%**. |
| **Root cause** | **~15–17s** pod cold start; **`context_builder` 3.8–6.2s**; ~750ms queue wait. LLM/retrieval not dominant. |
| **Outcome** | **Documented:** Led to PERF-002/003. |
| **Artifacts** | [RUN-2026-06-17.md](investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) |

#### 2026-06-17 — Load CSV has no `context_builder` column (documented)

| | |
|---|---|
| **Problem** | Metrics CSV is Locust + HPA only; span duration is Jaeger-only. |
| **Outcome** | **Documented:** Optional OTLP→Prometheus tracked as OBS-002 (**open**). |

#### PERF-003 — Context builder cache (resolved)

| | |
|---|---|
| **Problem** | `context_builder` **3.8–6.2s**; redundant SQL per request. |
| **Outcome** | **Resolved:** TTL cache, financial path fix, `context.cache_hit` spans; image `cxr-analyzer:perf003`. |
| **Artifacts** | [context-builder-optimization.md](investigations/planned/context-builder-optimization.md) · branch `perf-003-context-builder-optimize` |

#### PERF-002 — Context builder span tree (resolved)

| | |
|---|---|
| **Problem** | Opaque single Jaeger span. |
| **Outcome** | **Resolved:** `context.1_patient` … `context.7_policy` + SQL sub-spans. |

#### 2026-06-08 — LOAD-003b: maxReplicas 20 regression (documented)

| | |
|---|---|
| **Problem** | Raising caps to **20/20** destabilized run vs **8/5** baseline. |
| **Outcome** | **Documented:** More replicas ≠ more capacity on one node. |
| **Artifacts** | `load-20260608-182451.csv` vs `load-20260608-125236.csv` |

#### 2026-06-07/08 — LOAD-003 baseline (resolved)

| | |
|---|---|
| **Problem** | Does K8 HPA beat single-process LOAD-002 (~15–16 RPS)? |
| **Outcome** | **Resolved:** **~20–50 RPS** at saturation; HPA scales before single-process ceiling. |
| **Artifacts** | [kubernetes-analyzer-saturation](investigations/kubernetes-analyzer-saturation/README.md) |

#### Grafana HPA dual-axis misread (documented)

| | |
|---|---|
| **Problem** | “125 replicas” read from CPU axis (actually **125% CPU**). |
| **Outcome** | **Documented:** Read replica lines on right axis (0–8). |

### Latency & analyzer architecture (earlier)

#### Long-running analyzer migration (resolved)

| | |
|---|---|
| **Problem** | Claim analysis **~10–12s** under load; subprocess-per-request import cost. |
| **Outcome** | **Resolved:** Warm analyzer on **:8766**; p95 **~1.5s**; traces **~154–708ms** warm. |
| **Artifacts** | [ADR-004](architecture/adrs/ADR-004-long-running-analyzer.md) · [python-import-bottleneck](investigations/postmortems/python-import-bottleneck.md) · [latency-investigation](investigations/latency-investigation/README.md) |

### Investigations — backlog / planned

| ID | Area | Summary | Status |
|----|------|---------|--------|
| SCALE-003 | Investigations | UI bottleneck at peak load | Open |
| OBS-002 | Investigations | `context_builder` in Prometheus | Open |
| GIT-001 | Operations | Argo/Git values drift | Open |

*Automation track (load gate, KEDA, VPA) is documented in ops-lab on branch `feature/load-perf-automation`—not merged to portfolio yet.*

---

## Architecture

System design, ADRs, observability model, evolution narrative.

#### ADR-004 — Long-running analyzer (resolved)

| | |
|---|---|
| **Decision** | Replace subprocess analyze with persistent `analyzer_service` (:8766). |
| **Artifacts** | [ADR-004](architecture/adrs/ADR-004-long-running-analyzer.md) · [architecture-evolution.md](archive/architecture-c4/architecture-evolution.md) |

#### Detailed trace profile by default (documented)

| | |
|---|---|
| **Decision** | Reject “minimal” Jaeger profiles that hide startup/import/`context_builder` cost. |
| **Artifacts** | [missing-spans](investigations/missing-spans/README.md) · `CXR_TRACE_PROFILE=detailed` |

#### LOAD-003 scaling layers (documented)

| | |
|---|---|
| **Decision** | Document HPA vs cluster autoscaler vs metrics-server vs node capacity. |
| **Artifacts** | [ARCHITECTURE-scaling-layers.md](investigations/kubernetes-analyzer-saturation/ARCHITECTURE-scaling-layers.md) |

---

## Operations

Deploy, GitOps, observe stack, CI/CD.

#### Stale Docker `:local` image on K8 rollout (resolved)

| | |
|---|---|
| **Problem** | Rebuilt image not picked up; `IfNotPresent` + same tag digest. |
| **Outcome** | **Resolved:** Explicit tags (`perf003`) or digest pin. |

#### OBS-001 observe stack (documented)

| | |
|---|---|
| **Outcome** | Grafana `cxr-hpa-load-003`, Prometheus, Jaeger 2.19 for LOAD-003. |
| **Artifacts** | `cxr-ops-lab/docs/K8-LOAD-OBSERVE-RUNBOOK.md` |

#### GitOps phase demo (documented)

| | |
|---|---|
| **Artifacts** | [operations/ci-cd.md](operations/ci-cd.md) · `cxr-ops-lab/docs/GITOPS-PHASE-DEMO.md` |

---

## Demo

Local walkthroughs and stakeholder-facing material.

| Date | Entry |
|------|--------|
| — | *Add demo session notes here* — [archive/demo/RUN.md](archive/demo/RUN.md) |

---

## Archive

Superseded or reference-only material; kept for audit trail.

| Date | Entry |
|------|--------|
| — | [archive/README.md](archive/README.md) — supplemental architecture/platform thinking |
| — | [archive/meta/PORTFOLIO-STATUS.md](archive/meta/PORTFOLIO-STATUS.md) — portfolio meta |

---

## Platform

This repository and lab workspace.

#### 2026-06-18 — Portfolio changelog established (resolved)

| | |
|---|---|
| **Problem** | Progress scattered across investigations; hard for reviewers to see mistakes, fixes, and arc. |
| **Outcome** | **Resolved:** Root [CHANGELOG.md](CHANGELOG.md) (this file) as project-wide audit log. |
| **Note** | Per-study READMEs + evidence folders unchanged; changelog is the index of record. |

#### Lab workspace (multi-root) (documented)

| | |
|---|---|
| **Artifacts** | [cxr-lab.code-workspace](cxr-lab.code-workspace) · [lab-workflow.mmd](architecture/diagrams/lab-workflow.mmd) |

---

## Current lab snapshot (LOAD/K8 — 2026-06-18)

Quick reference for reviewers; details in investigation entries above.

| Setting | Value |
|---------|-------|
| Analyzer image | `cxr-analyzer:perf003` |
| Analyzer replicas | min **2**, max **8** |
| UI replicas | max **5** |
| Known knee | ~**100–120 users** stable on Docker Desktop; **200** still fails |

---

*Last structured update: 2026-06-18*

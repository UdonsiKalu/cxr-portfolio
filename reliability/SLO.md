# CXR service level objectives (SLO)

| | |
|---|---|
| **Status** | Draft — lab-evidenced; production targets proposed, not yet measured in prod |
| **Owner** | CXR platform / reliability |
| **Last updated** | 2026-06-19 |
| **Related** | [LOAD-003](../investigations/kubernetes-analyzer-saturation/README.md) · [GATE-001](../../cxr-ops-lab/docs/K8-LOAD-GATE.md) · [alerting strategy](../investigations/planned/alerting-strategy.md) |

---

## Purpose

Define **what “good enough” means** for CXR Claim Studio and the analyzer tier: what we measure (SLIs), what we promise internally (SLOs), how we burn error budget, and how load gates map to release decisions.

This document follows industry practice from [Google SRE](https://sre.google/sre-book/service-level-objectives/) and [OpenSLO](https://openslo.com/): user-journey SLIs, rolling windows, error budgets, and alerts on **burn rate** — not raw metric noise.

**Honesty boundary:** Evidence today is from **local lab** (Docker Desktop K8, synthetic Locust traffic). Production SLOs below are **proposed** until measured on real traffic and infrastructure.

---

## Vocabulary

| Term | Definition |
|------|------------|
| **SLI** | Service Level **Indicator** — a measurable proxy for user experience (e.g. p95 latency of successful analyze requests). |
| **SLO** | Service Level **Objective** — target SLI over a time window (e.g. 99% of analyze requests complete &lt; 5s over 30 days). |
| **SLA** | Service Level **Agreement** — contractual commitment with customers; **not defined here** (CXR is pre-production). |
| **Error budget** | Allowed unreliability: if SLO = 99.9% availability, budget = 0.1% downtime per window. When budget is exhausted, prioritize stability over features. |
| **Release gate** | Automated pass/fail on deploy (GATE-001/002) — stricter or load-specific; not the same as a 30-day production SLO. |

---

## User journeys (what we SLO)

Prioritize **critical paths** only. Do not SLO every endpoint.

| Journey | Endpoint / signal | User expectation |
|---------|-------------------|------------------|
| **J1 — Analyze claim** | `POST /api/claim-studio/analyze` | Timely, correct analysis with traceable evidence |
| **J2 — Open Claim Studio** | `GET /claim-studio` | UI loads and is interactive |
| **J3 — Analyzer health** | `GET /health` (analyzer) | Dependency ready for routing traffic |
| **J4 — Platform stability** | K8 replicas, pending pods, scrape health | No thrashing collapses under expected load |

**Primary SLO surface:** **J1** (analyze). J2–J4 are supporting SLIs for operability and capacity.

---

## SLIs and measurement

### J1 — Analyze latency (primary)

| Field | Value |
|-------|--------|
| **SLI** | Proportion of successful `POST /api/claim-studio/analyze` requests with end-to-end latency ≤ threshold |
| **Measurement** | Locust (synthetic) or ingress/service mesh histogram (production) |
| **Good event** | HTTP 2xx and latency ≤ threshold |
| **Bad event** | HTTP 5xx/timeout or latency &gt; threshold |
| **Exclusions** | Warm-up window after deploy; deliberate chaos drills (documented) |

**Why p95 (and p99), not mean:** Analyze is tail-heavy (context build, retrieval, LLM). Mean hides bad experiences; industry standard for latency SLOs is percentile-based.

### J1 — Analyze availability

| Field | Value |
|-------|--------|
| **SLI** | Proportion of analyze requests that return success (2xx) |
| **Good event** | HTTP 2xx within client timeout |
| **Bad event** | HTTP 5xx, connection reset, timeout |

### J2 — UI availability

| Field | Value |
|-------|--------|
| **SLI** | `GET /claim-studio` success rate |
| **Note** | Under analyze-heavy load, UI is a **proxy bottleneck** (LOAD-003, GATE-002). Track separately from analyzer. |

### J4 — Scaling stability (operational SLI)

| Field | Value |
|-------|--------|
| **SLI** | No replica **collapse** (≥5 → ≤2 analyzer replicas) during sustained load |
| **SLI** | Pending pod count for `cxr-ui-*` / `cxr-analyzer-*` below threshold |
| **Source** | `cxr-load-exporter` CSV / Prometheus (`cxr_replica_collapse`, `cxr_*_pending_pods`) |

---

## SLO targets by environment

Industry practice: **same SLI definitions**, **different targets** per environment. Staging/lab can be stricter on synthetic load; production optimizes for real user pain.

### Production (proposed — not yet measured)

| SLO ID | Journey | Objective | Window | Error budget |
|--------|---------|-----------|--------|--------------|
| **SLO-P1** | J1 latency | **99%** of analyze requests **&lt; 10s** (p99-style threshold on good requests) | 30 rolling days | **1%** slow requests |
| **SLO-P2** | J1 availability | **99.5%** successful analyze responses | 30 rolling days | **0.5%** failed requests |
| **SLO-P3** | J2 availability | **99.9%** successful page loads | 30 rolling days | **0.1%** failures |

**Rationale for 10s analyze:** Lab p95 at 200 synthetic users reached ~0.8–0.9s (GATE-002 pass); OBS-001 saw ~9s p95 at failure. Production SLO should reflect **interactive analyst workflow**, not lab saturation — start conservative, tighten with evidence.

### Staging / lab — steady load (warm, low concurrency)

| SLO ID | Journey | Objective | Window |
|--------|---------|-----------|--------|
| **SLO-L1** | J1 latency | **p95 &lt; 5s** at ≤ 15 concurrent users | Per gate run |
| **SLO-L2** | J1 availability | **failures/s ≤ 0.1** | Per gate run |
| **SLO-L3** | J3 health | Analyzer `/health` 200 after warm | Preflight |

*Aligns with legacy dev notes in [archive slos-and-slis](../archive/investigations-supplemental/slos-and-slis.md).*

### Staging / lab — capacity gate (LOAD-003 / GATE-002)

Synthetic **analyzer saturation**: 100% `POST /api/claim-studio/analyze`, cumulative ramp 15→200 users.

These are **release / capacity SLOs** — pass/fail for “can we ship this Helm config?” — not monthly production promises.

| Checkpoint (users) | p95 ceiling | failures/s | Collapses |
|--------------------|-------------|------------|-----------|
| 50 | ≤ 3s | ≤ 0.5 | 0 |
| 100 | ≤ 5s | ≤ 0.5 | 0 |
| 150 | ≤ 7s | ≤ 0.5 | 0 |
| 200 | ≤ 9s | ≤ 0.5 | 0 |

*Source of truth for automation:* `cxr-ops-lab/tuner_config.yaml` (`slos` block) and `k8-load-gate.sh`.

**Observed baseline (2026-06-19, GATE-002 c2 pass):** @200 users — p95 **~810ms**, **0** failures/s, **~98 RPS**, UI maxReplicas **4**, analyzer minReplicas **2**.

---

## Error budget policy

Industry practice ([multi-window multi-burn-rate](https://sre.google/workbook/alerting-on-slos/)):

| Burn rate | Window | Meaning | Action |
|-----------|--------|---------|--------|
| **Fast burn** | 1h | Budget consumed &gt; 2% in 1h | Page / stop deploys |
| **Slow burn** | 6h | Budget consumed &gt; 5% in 6h | Ticket, freeze risky changes |
| **Budget exhausted** | 30d | &lt; 0% remaining | **Feature freeze** until reliability work ships |

**Lab / gates:** Error budget is **per run** — a failed GATE-002 candidate does not consume production budget; it blocks promoting that Helm recipe.

---

## Alerting (linked to SLOs)

Alerts fire on **SLO burn rate**, not isolated spikes.

| Alert | Condition (draft) | Severity |
|-------|-------------------|----------|
| Analyze fast burn | &gt;1% failures or p95 &gt; 10s for 5m at &gt;10 RPS | Critical |
| Analyze slow burn | SLO-P2 budget &gt;10% consumed in 24h | Warning |
| Replica collapse | `cxr_replica_collapse == 1` for 2m | Warning |
| Pending pods | `cxr_ui_pending_pods &gt; 0` or `cxr_analyzer_pending_pods &gt; 2` for 5m | Warning |
| Scrape down | `cxr_exporter_poll_ok == 0` for 2m | Critical (observability) |

Full design: [investigations/planned/alerting-strategy.md](../investigations/planned/alerting-strategy.md).

Prometheus rules (partial): `cxr-ops-lab/observe/prometheus/cxr_recording_rules.yml` (`cxr_load_stable`).

---

## Release gates vs production SLOs

| | **Release gate (GATE-001/002)** | **Production SLO** |
|--|--------------------------------|---------------------|
| **Purpose** | Block bad deploys / tune Helm | Protect users over 30 days |
| **Traffic** | Synthetic Locust | Real or representative |
| **Duration** | ~40 min per candidate | 30 rolling days |
| **Failure** | CI/red gate, no promote | Error budget burn, incident response |
| **Latency** | Tiered by load (3s→9s @ 50→200 users) | Single user-centric threshold (e.g. 99% &lt; 10s) |

**Industry practice:** Gates should be **stricter than or equal to** SLO at equivalent load — never looser without explicit risk acceptance.

---

## What we explicitly do not SLO (yet)

- LLM token cost / model quality scores (separate eval track — Langfuse)
- Qdrant recall@k (correctness SLI — future ADR)
- Per-tenant fairness under multi-tenant prod
- End-to-end billing or auth (not in scope)

---

## Review cadence

| Activity | Frequency |
|----------|-----------|
| SLO target review | Quarterly |
| Gate threshold review | After each LOAD arc or major perf change |
| Error budget retrospective | Monthly (when in production) |
| SLI implementation audit | When metrics pipeline changes |

---

## Evidence map

| Claim | Evidence |
|-------|----------|
| Saturation gate thresholds | `cxr-ops-lab/tuner_config.yaml`, `docs/K8-LOAD-GATE.md` |
| OBS-001 failure mode | [RUN-2026-06-17](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) |
| GATE-002 passes | `investigations/kubernetes-analyzer-saturation/results/tuner/result-c*-20260619-080505.json` |
| UI maxReplicas=5 risk | c1 fail vs c2/c3 pass in tuner `080505` stamp |
| Node low / pod scheduling | LOAD-003 Grafana, portfolio CHANGELOG |

---

## Open actions

1. Wire analyzer replica SLI in exporter (KEDA-aware) — **fixed on branch `feature/perf-008-queue-backpressure`** (Deployment readyReplicas); merge + verify under load.
2. Promote production SLO-P* after first staging with real-shaped traffic.
3. Implement multi-burn-rate alert rules in Prometheus/Alertmanager.
4. Add lightweight mixed profile SLO row (75% UI / 25% analyze) separate from saturation gate.
5. OpenSLO YAML export (optional) for GitOps — `reliability/openslo/` when targets stabilize.

---

## References

- Google SRE Book — [Chapter 4: SLOs](https://sre.google/sre-book/service-level-objectives/)
- Google SRE Workbook — [Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
- [OpenSLO specification](https://openslo.com/)
- [Grafana SLO best practices](https://grafana.com/docs/grafana-cloud/alerting-and-irm/slo/)

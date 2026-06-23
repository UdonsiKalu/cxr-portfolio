# GATE-002 — KEDA + Helm grid study (first KEDA apply)

| | |
|---|---|
| **ID** | GATE-002 |
| **Date** | 2026-06-19 (stamp `080505`) |
| **Depends on** | KEDA installed (`cxr-ops-lab/scripts/11-keda-install.sh`), load gate ([K8-LOAD-GATE.md](https://github.com/UdonsiKalu/cxr-ops-lab/blob/feature/perf-008-queue-backpressure/docs/K8-LOAD-GATE.md)) |
| **Profile** | Analyze-only cumulative ramp 15→200 users (OBS-comparable) |
| **Evidence** | [tuner-summary-20260619-080505.json](../results/tuner/tuner-summary-20260619-080505.json) |

This is the **first time KEDA replaced CPU-only HPA** on `cxr-analyzer` in a controlled, repeatable way. We did not hand-pick one Helm overlay — we ran a **12-point grid search** over deploy-time caps while KEDA scaled replicas at runtime from **CPU + Locust E2E p95**.

---

## Why we ran a grid (not one-off tuning)

After OBS-001 (Jun 17) and the Jun 18 regressions, manual Grafana tuning was not reproducible. GATE-002 answers:

> *Given KEDA on the analyzer, which combination of **analyzer/UI replica bounds** passes the same load gate every time?*

Runtime scaling (how many pods) is KEDA’s job. The grid searches **configuration** KEDA and HPA must live inside.

---

## What KEDA was doing on every candidate

All 12 runs used the same ScaledObject pattern (see `cxr-ops-lab/helm/cxr-analyzer`):

| Trigger | Signal | Threshold |
|---------|--------|-------------|
| CPU | `cpu` utilization | 70% |
| Prometheus | `cxr_locust_p95_ms` (via load exporter) | **2000 ms** |

Legacy CPU-only **HPA was removed** when KEDA is enabled (`ScaledObject` owns scale). Stack install: `06-helm-install-stack.sh` + `11-keda-install.sh`.

**Not varied in this grid:** KEDA p95 threshold (fixed at 2000 ms), trigger types, or load ramp shape. PERF-008 later A/B-tested **inflight/pod** as an alternate KEDA signal.

---

## Grid dimensions (search space)

From `cxr-ops-lab/tuner_config.yaml` — Cartesian product = **12 candidates**:

| Knob | Values searched |
|------|-----------------|
| `analyzer.autoscaling.maxReplicas` | 6, 8, 10 |
| `analyzer.autoscaling.minReplicas` | 1, 2 |
| `autoscaling.keda.prometheus.p95ThresholdMs` | 2000 (fixed) |
| `ui.autoscaling.maxReplicas` | 4, 5 |

**Held constant:** analyze-only Locust profile, `perf003` image, tiered gate SLOs (p95 3s→9s @ 50→200 users), **0** replica collapses, **≤0.5** failures/s.

**Runner:** `cxr-ops-lab/scripts/k8-load-tuner.sh` — applies each recipe via Helm, runs `k8-load-gate.sh`, scores, picks lowest score among passes.

---

## Results @ 200 users (stamp `080505`)

| Cand. | Analyzer max | Analyzer min | UI max | Gate | @200 RPS | @200 p95 | @200 failures/s |
|-------|-------------|-------------|--------|------|----------|----------|-----------------|
| c0 | 6 | 1 | 4 | PASS | 95.0 | 930 ms | 0 |
| **c1** | 6 | 1 | **5** | **FAIL** | 116.0 | 920 ms | **116** |
| c2 | 6 | 2 | 4 | PASS | 98.1 | 810 ms | 0 |
| c3 | 6 | 2 | 5 | PASS | 93.4 | 890 ms | 0 |
| **c4** | **8** | **1** | **4** | **PASS** | **102.1** | **820 ms** | **0** |
| c5 | 8 | 1 | 5 | PASS | 97.5 | 850 ms | 0 |
| c6 | 8 | 2 | 4 | PASS | 93.9 | 920 ms | 0 |
| c7 | 8 | 2 | 5 | PASS | 96.6 | 920 ms | 0 |
| c8 | 10 | 1 | 4 | PASS | 100.5 | 850 ms | 0 |
| c9 | 10 | 1 | 5 | PASS | 98.4 | 840 ms | 0 |
| c10 | 10 | 2 | 4 | PASS | 98.2 | 870 ms | 0 |
| c11 | 10 | 2 | 5 | PASS | 95.6 | 900 ms | 0 |

**Score:** 11/12 passed. **Winner: candidate 4** (best throughput among passes — 102.1 RPS, lowest gate score).

Per-candidate JSON: [results/tuner/](../results/tuner/README.md).

---

## What the one failure taught us

**Candidate 1** (UI `maxReplicas=5`, analyzer `minReplicas=1`) is the only grid point that failed. Grafana shows UI HPA at cap with volatile CPU while analyzer replicas stayed flat — the **UI forward path** saturated before the analyzer tier.

![GATE-002 c1 — 116 failures/s @ 200](../evidence/failures/grafana-gate-c1-fail-20260619.png)

That failure shape is why the winning recipe caps UI at **4** replicas, not 5.

![GATE tuner — UI thrash, analyzer replicas flat](../evidence/failures/grafana-gate-tuner-analyzer-replicas-zero.png)

Four back-to-back cumulative ramps on the same day show the same UI-thrash pattern on non-winning configs:

![GATE tuner — four cumulative ramps (grid session)](../evidence/failures/grafana-gate-tuner-multi-cycle-20260619.png)

---

## Winner (deploy recipe)

```yaml
analyzer:
  autoscaling.maxReplicas: 8
  autoscaling.minReplicas: 1
  autoscaling.keda.prometheus.p95ThresholdMs: 2000
ui:
  autoscaling.maxReplicas: 4
```

This became the **baseline Helm overlay** for later work, including PERF-008 Experiment A (same KEDA triggers; validated again with OBS-002 replica truth and `perf008` metrics).

**Not yet on git `main`:** tracked as [GIT-001](https://github.com/UdonsiKalu/cxr-portfolio/issues/24) — winner lives in lab evidence until Argo-managed values merge.

---

## Relationship to PERF-008

| Study | Question |
|-------|----------|
| **GATE-002 (this doc)** | First KEDA apply — which **Helm caps** pass the gate with **p95 + CPU** KEDA? |
| **PERF-008** | Given winner caps, is **inflight/pod** a *better KEDA signal* than p95? (Answer: no — B failed gate.) |

Read [PERF-008-queue-depth-autoscaling.md](PERF-008-queue-depth-autoscaling.md) for the A/B after this grid.

---

## Related

- [failures/README.md](../failures/README.md) — narrative arcs (Arc 4)  
- [history.md](history.md) — program timeline  
- [CHANGELOG.md](../CHANGELOG.md) — dated GATE-002 entry  
- Ops runbook: `cxr-ops-lab/docs/K8-LOAD-GATE.md`

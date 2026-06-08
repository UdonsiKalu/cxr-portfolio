# Scaling layers — HPA vs cluster autoscaler (LOAD-003 reference)

## What we have in the cxr-lab stack

| Layer | Component | Role in this lab |
|-------|-----------|------------------|
| **Metrics** | **metrics-server** (+ optional Prometheus `:9090`) | Supplies **CPU/memory** pod and node usage to HPA and `kubectl top` |
| **Scheduling** | **kube-scheduler** | Places pods on nodes using **requests/limits** |
| **Pod autoscale** | **HPA** (`cxr-analyzer`, `cxr-ui`) | Adds **pods** when avg CPU vs **requests** crosses target (70% / 80%) |
| **Node autoscale** | **Not configured** | **kind** = single static node; no Cluster Autoscaler / Karpenter |

## HPA (Horizontal Pod Autoscaler) — **what LOAD-003 proved**

- Watches **Deployment** replica count.
- Reads **metrics-server** CPU % **relative to pod `resources.requests.cpu`**.
- Scales **pods in/out** between `minReplicas` and `maxReplicas`.
- **Does not add nodes** — if the node is full, new pods stay **Pending** (seen at 4/4 analyzer replicas).

## Cluster Autoscaler / Karpenter — **true dynamic expansion (production)**

| | Cluster Autoscaler | Karpenter |
|---|-------------------|-----------|
| **Adds** | VM / node pool capacity | Nodes (often faster, bin-packing) |
| **When** | Pods **Pending** due to insufficient node resources | Same + proactive optimization |
| **kind lab** | **N/A** | **N/A** |

**Production path:** HPA adds pods → Pending → CA/Karpenter adds nodes → scheduler binds pods.

## Resource requests / limits — **why they matter for HPA**

From `helm/cxr-analyzer/values.yaml`:

- **requests:** `cpu: 500m`, `memory: 2Gi` — HPA CPU % is measured against **requests**, not limits.
- **limits:** `cpu: 2`, `memory: 6Gi` — cap per pod; throttling/OOM if exceeded.

If requests are too low, HPA sees **300%+ CPU** while pods still fit on the node (LOAD-003 screenshot). If too high, HPA scales late.

## Prometheus vs metrics-server

| | metrics-server | Prometheus |
|---|----------------|------------|
| **HPA default** | Yes (Resource metrics) | Custom metrics via adapter |
| **Lab** | Installed (`09-metrics-server-install.sh`) | Optional (`07-observe-up.sh` `:9090`) |
| **Future** | CPU-only analyzer HPA | RPS, p95, queue depth → smarter HPA |

## LOAD-003 observed signature (2026-06-08)

1. **RPS** rose from **~15–16** (LOAD-002 single analyzer) to **~20** with **3–4** analyzer pods.
2. **HPA** hit **maxReplicas**; **309% / 70%** CPU target on analyzer.
3. **Node** saturated → **1 Pending** analyzer + **pod restarts**.
4. **Failures** appeared (~0.43/s) as **node-level** limit, not application logic.

**Conclusion:** HPA **works for pod scaling**; **kind single-node** is the lab ceiling. Production needs **CA/Karpenter + multi-node** for “true” elastic expansion.

See [ADR-future-gpu-analyzer-scaling.md](./ADR-future-gpu-analyzer-scaling.md) for CPU vs GPU worker scaling.

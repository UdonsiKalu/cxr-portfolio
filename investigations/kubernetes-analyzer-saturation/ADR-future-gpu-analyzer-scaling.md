# ADR (future): CPU-only analyzer HPA vs GPU-backed analyzer workers

| | |
|---|---|
| **Status** | Proposed — not decided |
| **Context** | LOAD-002 / LOAD-003 — warm analyzer is CPU-heavy (torch, faiss CPU, embeddings) |
| **Investigation** | [kubernetes-analyzer-saturation/](./README.md) · [LOAD-002](../analyzer-saturation/) |

## Problem

CXR analyzer pods on **CPU-only** images (`Dockerfile.analyzer` — CPU torch/faiss) hit a **throughput knee** (~15–16 RPS per warm process, LOAD-002). HPA scales **replicas**, not **per-pod compute class**.

## Options

### A — CPU-only HPA (current lab)

- **Pros:** Simple kind/Helm path; matches current `cxr-analyzer:local` image; HPA on CPU works today.
- **Cons:** Linear cost in **replicas**; each pod ~7–10 min warm boot; embedding/RAG still CPU-bound; node saturation (LOAD-003 Pending pods).

### B — GPU-backed analyzer workers

- **Pros:** Higher per-pod throughput for embeddings / optional GPU faiss; fewer replicas for same RPS.
- **Cons:** Requires GPU nodes, device plugin, CUDA base image, different **requests/limits** (`nvidia.com/gpu: 1`); HPA on CPU alone is **wrong signal** — need custom metrics (RPS, queue lag) or GPU util via DCGM + Prometheus adapter; not available on typical kind laptop lab.

### C — Hybrid

- CPU pods for “light” analyze path; GPU **worker pool** for embedding-heavy stages (queue-based) — aligns with syllabus **M7** / NeuralGate split.

## Recommendation (draft)

1. **Short term (portfolio / bootcamp):** Document **CPU HPA** path (LOAD-003) as **pod horizontal scaling** proof.
2. **Production:** Evaluate **Option C** if p95 SLA requires >~20 RPS per replica on CPU; pilot GPU worker Deployment with **custom HPA** (Prometheus RPS or Keda).
3. **Do not** enable GPU in kind lab until hardware + image pipeline exist.

## Open questions

- Does embedding dominate analyze latency enough to justify GPU vs more CPU replicas?
- Can warm boot be amortized with **`minReplicas > 1`** and pre-warmed pool?
- Karpenter node pool: `cpu-analyzer` vs `gpu-analyzer` taints/tolerations?

## Decision

**Deferred** — revisit after LOAD-003 published + optional GPU hardware availability.

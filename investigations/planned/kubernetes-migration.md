# PLATFORM-002 — Kubernetes migration

**Status:** Partial — UI tier done as [kubernetes-deploy/](../kubernetes-deploy/) (K8-001). Multi-service migration remains Phase 2.

| Field | |
|-------|---|
| **Question** | What would a full K8s deployment of CXR look like? |
| **Done (K8-001)** | **`kind cxr-lab`** + Helm **`cxr-ui:local`** + **:8081** — UI shell only |
| **Remaining** | Analyzer API, Qdrant, ingress, HPA — see [autoscaling](./autoscaling.md), [horizontal-scaling](./horizontal-scaling.md) |
| **Method** | Design from LOAD-001/002 capacity + K8-001 deploy path |
| **Tools** | `cxr-ops-lab` Helm, optional Argo SW.8 |

## Follow-up

After [kubernetes-deploy/](../kubernetes-deploy/) and [horizontal-scaling](./horizontal-scaling.md).

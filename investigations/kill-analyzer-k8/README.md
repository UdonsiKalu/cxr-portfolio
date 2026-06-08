# Kill analyzer under traffic — K8 (REL-001-K8 / CHAOS-002)

| | |
|---|---|
| **Status** | Runbook ready |
| **ID** | REL-001-K8 · CHAOS-002 |
| **Component** | `cxr-analyzer` pods on **Docker Desktop K8** — UI **:8081** |
| **Builds on** | [CHAOS-001](../kill-analyzer-under-traffic/) · [LOAD-003](../kubernetes-analyzer-saturation/) · [GITOPS-001](../gitops-deploy/) |
| **Environment** | `kubectl config use-context docker-desktop` |

---

## Question

When an **analyzer pod** is deleted during Locust load on **:8081**, how fast does Kubernetes + HPA restore throughput?

## Hypothesis

Deleting one analyzer pod causes brief **5xx** until replacement is **Ready**; HPA may add replicas under sustained load; post-recovery p95 returns near LOAD-003 steady state.

## Method

1. GitOps stack healthy: `./scripts/14-argo-verify.sh` (cxr-ops-lab).
2. Warm stack: `./scripts/16-k8-stack-verify.sh` → **:8081** HTTP 200, `warmed: true`.
3. Locust on **:8081** — moderate users (e.g. **20**), POST `/api/claim-studio/analyze`.
4. After **30s** baseline, delete one analyzer pod:  
   `kubectl delete pod -n cxr-ui -l app=cxr-analyzer --field-selector=status.phase=Running --wait=false | head -1`
5. Watch HPA: `./scripts/k8-hpa-watch.sh` or `kubectl get hpa -n cxr-ui -w`.
6. Record failures, recovery time, replica count.

Automated: [`run-kill-analyzer-k8.sh`](./run-kill-analyzer-k8.sh)

---

## Run

```bash
cd ~/staging/cxr-ops-lab
kubectl config use-context docker-desktop
./scripts/16-k8-stack-verify.sh

# From portfolio repo
./investigations/kill-analyzer-k8/run-kill-analyzer-k8.sh
```

---

## Evidence checklist

- [ ] Locust failure spike during pod kill window
- [ ] HPA replica line during recovery (`kubectl get hpa` or LOAD-003 collector)
- [ ] Post-recovery success rate + p95

Save under `results/` and `screenshots/`.

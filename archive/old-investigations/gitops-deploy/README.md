# GitOps deploy (GITOPS-001)

| | |
|---|---|
| **Status** | Complete (infra + runbook 2026-06-08) |
| **ID** | GITOPS-001 |
| **Component** | Argo CD on **Docker Desktop K8** — `helm/cxr-ui` + `helm/cxr-analyzer` from **`cxr-ops-lab`** Git |
| **Builds on** | [kubernetes-deploy](../kubernetes-deploy/) · [kubernetes-analyzer-saturation](../kubernetes-analyzer-saturation/) (LOAD-003) |
| **CD chain** | [CI-001](../ci-pipeline/) (app) → **CD-001** (values bump) → Argo sync |

---

## Question

Can CXR K8 config deploy from **Git** via **Argo CD** instead of manual `helm upgrade` / `kubectl apply`?

## Hypothesis

Editing `helm/*/values.yaml` in **`cxr-ops-lab`**, pushing to GitHub, and letting Argo CD watch the repo will keep **cxr-ui** and **cxr-analyzer** **Synced/Healthy** on **docker-desktop**.

## GitOps loop

```text
Edit helm/cxr-analyzer/values.yaml or helm/cxr-ui/values.yaml
        ↓
git commit + push (cxr-ops-lab main)
        ↓
Argo CD detects drift → sync
        ↓
Kubernetes updates pods / HPA
```

**Daily dev :8251** stays outside this loop (Compose/rehearsal).

---

## Install (one-time)

```bash
cd ~/staging/cxr-ops-lab && export PATH="$PWD/bin:$PATH"
kubectl config use-context docker-desktop
./scripts/13-argo-install.sh
./scripts/14-argo-verify.sh
```

Argo UI: `kubectl port-forward svc/argocd-server -n argocd 8083:443` → https://localhost:8083

---

## Change config (GitOps path)

```bash
# Example: raise analyzer maxReplicas
vim helm/cxr-analyzer/values.yaml   # maxReplicas: 12
git add helm/cxr-analyzer/values.yaml
git commit -m "gitops: raise analyzer maxReplicas"
git push origin main
# Argo syncs within ~1–3m (automated syncPolicy)
./scripts/14-argo-verify.sh
```

Local marker bump (CD-001 dry-run):

```bash
./scripts/cd-bump-deploy-marker.sh local-test-001
git add helm/*/values.yaml && git commit -m "cd: local marker" && git push
```

---

## CI / CD wiring

| Step | Repo | Workflow |
|------|------|----------|
| **CI-001** (app tests) | `cxr-ui-rehearsal` | `.github/workflows/ci.yml` |
| **CI extend** (analyzer Dockerfile) | `cxr-ops-lab` | `build-k8-images.yml` |
| **CD-001** (deploy marker) | `cxr-ops-lab` | `cd-gitops-bump.yml` → bumps `gitOpsDeployMarker` → Argo rollout |

Desktop K8 uses image tag **`local`** (same Docker daemon). Registry-based CD deferred for cloud.

---

## Evidence (2026-06-08)

Verified on **docker-desktop**:

```text
./scripts/13-argo-install.sh   # Argo CD + both Applications
./scripts/14-argo-verify.sh    # cxr-ui + cxr-analyzer Synced/Healthy
./scripts/16-k8-stack-verify.sh # warmed: true, :8081 HTTP 200
```

| Check | Result |
|-------|--------|
| Argo **cxr-ui** | Synced / Healthy |
| Argo **cxr-analyzer** | Synced / Healthy |
| Stack verify | ALL PASSED |
| GitOps source | `https://github.com/UdonsiKalu/cxr-ops-lab.git` main |

## Evidence checklist

- [x] Argo apps **cxr-ui** + **cxr-analyzer** **Synced / Healthy** (`14-argo-verify.sh`)
- [ ] Argo UI screenshot (optional PNG in `screenshots/`)
- [x] Git push → pod annotation `cxr.gitops/deploy-marker` = `gitops-001-verify` (CD-001)
- [x] `./scripts/16-k8-stack-verify.sh` **ALL PASSED** after sync

Save PNGs under `screenshots/` when captured.

---

## Related

- **OBS-001:** Grafana `cxr-hpa-load-003` dashboard (`observe/grafana/…`)
- **REL-001-K8:** [kill-analyzer-k8](../kill-analyzer-k8/)
- **REL-002-K8:** [qdrant-outage-k8](../qdrant-outage-k8/)
- **SCALE-001:** [kubernetes-analyzer-saturation/SCALE-001-fixed-replicas.md](../kubernetes-analyzer-saturation/SCALE-001-fixed-replicas.md)

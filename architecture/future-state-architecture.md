# Future state architecture

## Target (bootcamp / portfolio roadmap)

1. **Today:** `:8251` dev UI + `:8766` warm analyzer + observe stack (`cxr up`).
2. **SW.3 K8:** `kind` cluster `cxr-lab`; Deployment + Service for SW.1 image; port-forward **:8081**.
3. **SW.4 Helm:** `cxr-ops-lab/helm/cxr-ui` — image tag, env, replicas.
4. **SW.5 Terraform:** reproducible kind cluster (`cxr-ops-lab/terraform`).
5. **SW.8 Argo CD:** Application → Helm from Git.

Pods may reach **SQL/Qdrant on host** (syllabus-allowed out-of-cluster).

## Diagram

See K8 deploy intent in companion ops-lab and [operations/kubernetes/](../operations/kubernetes/).

## Not in scope unless requested

Production `cxrlabs-dev/platform/infra` gateway/analysis spine.

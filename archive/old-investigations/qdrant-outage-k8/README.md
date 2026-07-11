# Qdrant outage — K8 (REL-002-K8)

| | |
|---|---|
| **Status** | Runbook ready |
| **ID** | REL-002-K8 |
| **Component** | Qdrant on host **:6333** + analyzer pods (`host.docker.internal`) |
| **Builds on** | [DEP-001](../qdrant-outage/) · [GITOPS-001](../gitops-deploy/) |
| **Environment** | Docker Desktop K8 — UI **:8081** |

---

## Question

How does **:8081** analyze behave when host Qdrant is stopped while analyzer pods keep running?

## Hypothesis

Same as DEP-001: **HTTP 200** with degraded retrieval — K8 routing stays up; errors surface in analyzer logs, not necessarily as 500 to UI.

## Method

1. Qdrant running on host (`docker start cxr-qdrant-outage-lab` or `cxr up` Qdrant).
2. `./scripts/16-k8-stack-verify.sh` — warmed analyzer via **:8081**.
3. **Baseline** — `POST /api/claim-studio/analyze` via **:8081**.
4. **Stop Qdrant** — `docker stop cxr-qdrant-outage-lab` (or container name from DEP-001).
5. **Probe** — analyze again without pod restart.
6. **Recovery** — start Qdrant; probe again.

Automated: [`run-qdrant-outage-k8.sh`](./run-qdrant-outage-k8.sh)

---

## Run

```bash
cd ~/staging/cxr-ops-lab
kubectl config use-context docker-desktop
./scripts/16-k8-stack-verify.sh

./investigations/qdrant-outage-k8/run-qdrant-outage-k8.sh
```

---

## Evidence checklist

- [ ] Baseline / outage / recovery HTTP codes + latency table
- [ ] Analyzer pod logs showing Qdrant warnings

Save under `results/`.

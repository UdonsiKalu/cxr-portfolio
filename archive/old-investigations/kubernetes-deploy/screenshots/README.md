# Kubernetes deploy — evidence

| File | Description |
|------|-------------|
| `kubectl-get-all-cxr-ui.png` | **`kubectl get all -n cxr-ui`** — pod/deployment/service |
| `helm-list-cxr-ui.png` | **`helm list -n cxr-ui`** — chart **`cxr-ui-0.1.0`** deployed |
| `browser-localhost-8081.png` | Browser — http://127.0.0.1:8081 (K8 UI via port-forward) |

Terminal snapshot: [`../results/k8-cluster-snapshot-2026-06-07.txt`](../results/k8-cluster-snapshot-2026-06-07.txt)

**Regenerate:**

```bash
./scripts/capture-ci-k8-screenshots.sh
```

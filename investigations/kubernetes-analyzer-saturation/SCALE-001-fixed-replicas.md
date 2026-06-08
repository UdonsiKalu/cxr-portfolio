# SCALE-001 — fixed replicas (HPA off)

| | |
|---|---|
| **Status** | Optional experiment runbook |
| **ID** | SCALE-001 |
| **Question** | Throughput vs **fixed** replica count without HPA dynamics |
| **Builds on** | [LOAD-003](./README.md) (HPA 1→8) |

---

## Why

LOAD-003 proved **dynamic** HPA scaling. SCALE-001 isolates **replica count vs RPS** by holding replicas constant.

## Setup

Temporarily disable HPA or pin min = max in Helm values:

```yaml
# helm/cxr-analyzer/values.yaml
autoscaling:
  enabled: false
replicaCount: 3   # repeat for 1, 3, 5, 8

# helm/cxr-ui/values.yaml — match UI replicas or keep HPA on UI only
```

GitOps path:

```bash
vim helm/cxr-analyzer/values.yaml
git commit -am "scale-001: analyzer fixed replicas=3"
git push
./scripts/14-argo-verify.sh
```

## Run (each replica setting)

```bash
./scripts/16-k8-stack-verify.sh
./investigations/kubernetes-analyzer-saturation/run-k8-load-with-metrics.sh
python3 investigations/kubernetes-analyzer-saturation/plot_load_test.py \
  investigations/kubernetes-analyzer-saturation/results/load-*.csv
```

Compare RPS / p95 curves across **1, 3, 5, 8** fixed analyzer replicas.

## Restore

Re-enable HPA (`autoscaling.enabled: true`, `minReplicas`/`maxReplicas` as LOAD-003) and push via GitOps.

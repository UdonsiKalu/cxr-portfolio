# LOAD-004 — capacity-expanded autoscaling

| | |
|---|---|
| **Status** | Ready to run (infra prep 2026-06-08) |
| **ID** | LOAD-004 |
| **Builds on** | [LOAD-003](./README.md) · [LOAD-003 evidence](./evidence/load-003/) |
| **Cluster** | **kind `cxr-lab` expanded** — 1 control-plane + **2 workers** |
| **HPA limits** | analyzer **1–8** (was 4), UI **1–5** (was 3) |

---

## Question

If we raise **HPA maxReplicas** *and* add **node capacity** (multi-node kind), does aggregate **RPS** increase beyond LOAD-003 (~20 RPS), or does the **application** (SQL/Qdrant/warm boot) become the next bottleneck?

---

## Portfolio conclusion

LOAD-003 proved pod autoscaling was functioning, but the system saturated because autoscaling was bounded by HPA maxReplicas and single-node cluster capacity. The next experiment expands both HPA limits and node capacity to test whether throughput improves or whether the application itself becomes the next bottleneck.

---

## What changed vs LOAD-003

| Layer | LOAD-003 | LOAD-004 |
|-------|----------|----------|
| kind nodes | 1 (control-plane only) | **3** (1 CP + **2 workers**) |
| Analyzer HPA max | 4 | **8** |
| UI HPA max | 3 | **5** |
| Locust ramp | Same script / env | Same |

---

## Prep (one-time)

```bash
cd ~/staging/cxr-ops-lab && export PATH="$PWD/bin:$PATH"

# 1. Stop any :8081 Locust
pkill -f 'locust.*--host http://127.0.0.1:8081' || true

# 2. Recreate expanded cluster + redeploy (skips image rebuild if local tags exist)
chmod +x scripts/01-kind-recreate-expanded.sh
./scripts/01-kind-recreate-expanded.sh
CXR_SKIP_ANALYZER_BUILD=1 ./scripts/04-kind-load-images-only.sh
./scripts/06-helm-install-stack.sh
./scripts/16-k8-stack-verify.sh

# Confirm HPA caps
kubectl get hpa -n cxr-ui
# expect MAXPODS analyzer=8, ui=5
kubectl get nodes
# expect 3 nodes
```

---

## Run LOAD-004 (same ramp as LOAD-003)

**Terminal A — metrics CSV:**
```bash
cd ~/staging/cxr-portfolio
export CXR_LOCUST_URL=http://127.0.0.1:8092
./investigations/k8-hpa-autoscale/run-k8-load-with-metrics.sh
# saves to investigations/k8-hpa-autoscale/results/load-YYYYMMDD-HHMMSS.csv
```

**Terminal B — Locust GUI ramp:**
```bash
cd ~/staging/cxr-portfolio
CXR_LOAD_URL=http://127.0.0.1:8081 \
CXR_LOCUST_WEB_PORT=8092 \
CXR_RAMP_MAX_USERS=200 CXR_RAMP_START_USERS=15 CXR_RAMP_STEP_USERS=5 CXR_RAMP_STAGE_SECONDS=60 \
./investigations/analyzer-saturation/run-saturation-ramp-until-break-gui.sh
```

**Terminal C — watch:**
```bash
cd ~/staging/cxr-ops-lab
./scripts/k8-hpa-watch.sh
```

Stop when failures/p95 break (same criteria as LOAD-003). Save screenshots to `evidence/load-004/`.

**Plot (after run):**
```bash
python3 investigations/k8-hpa-autoscale/plot_load_test.py \
  investigations/k8-hpa-autoscale/results/load-YYYYMMDD-HHMMSS.csv \
  -o investigations/k8-hpa-autoscale/results/load-004-charts
```

---

## Compare LOAD-003 vs LOAD-004

| Metric | LOAD-003 | LOAD-004 (fill after run) |
|--------|----------|---------------------------|
| Nodes | 1 | 3 |
| Analyzer HPA max | 4 | 8 |
| UI HPA max | 3 | 5 |
| Peak users | ~195 | |
| Peak RPS | ~20 | |
| Peak analyzer replicas | 4 (1 Pending) | |
| Peak UI replicas | 3 | |
| p95 at stop | ~9s | |
| fail/s at stop | ~0.43 | |
| Pending pods | yes | |
| Pod restarts under load | yes | |

---

## Files

| Path | Purpose |
|------|---------|
| [evidence/load-003/](./evidence/load-003/) | LOAD-003 terminal + run summary |
| `evidence/load-004/` | LOAD-004 screenshots + snapshot (after run) |
| `cxr-ops-lab/kind/cxr-lab-expanded.yaml` | Multi-node kind config |
| `cxr-ops-lab/scripts/01-kind-recreate-expanded.sh` | Delete + recreate expanded cluster |

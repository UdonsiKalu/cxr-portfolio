# LOAD-003 evidence — K8 HPA autoscale (2026-06-08)

## Run parameters

| Setting | Value |
|---------|-------|
| Target | `http://127.0.0.1:8081` (K8 UI → in-cluster analyzer) |
| Locust | `run-saturation-ramp-until-break-gui.sh` on **:8092** |
| Ramp | start **15**, +**5** users / **60s**, cap **200** |
| Cluster | **kind `cxr-lab`** — **single node** (`cxr-lab-control-plane`) |
| HPA limits | analyzer **max 4**, UI **max 3** |

## Peak metrics (final frame before Stop)

| Metric | Value |
|--------|-------|
| Users | ~**195** |
| RPS | ~**20** (vs LOAD-002 **~15–16** on `:8251→:8766`) |
| p95 | ~**9s** |
| Failures | ~**0.43 fail/s** at stop |
| HPA analyzer | **4/4** replicas, **309%/70%** CPU |
| HPA UI | **3/3** replicas, **106%/80%** CPU |
| Scheduling | **3** analyzers Running, **1 Pending**, pod **restarts** |

## Conclusion (LOAD-003)

HPA **worked** — replicas scaled with load and aggregate RPS beat single-analyzer LOAD-002. Saturation was caused by **HPA maxReplicas** (4 analyzer / 3 UI) and **single-node kind capacity** (Pending pods, liveness restarts under pressure), not application crash.

## Artifacts

| File | Description |
|------|-------------|
| [post-run-cluster-snapshot.txt](./post-run-cluster-snapshot.txt) | Cluster state after stopping Locust (idle, post-load) |
| [../screenshots/](../screenshots/) | Copy Locust / HPA watch / Jaeger PNGs here |

Screenshots to add manually: `locust-final-195users.png`, `hpa-watch-4-replicas.png`, `jaeger-peak-optional.png`.

## Desktop K8 rerun (2026-06-08)

| Metric | Value |
|--------|-------|
| Cluster | **docker-desktop** (not kind) |
| HPA limits | analyzer **max 8**, UI **max 5** |
| Users | **200** |
| RPS | ~**50** (plot peak) |
| HPA analyzer | **8/8**, **330%/70%** |
| HPA UI | **5/5**, **110%/80%** |
| Chart | `results/charts/load-test-autoscaling.png` from `load-20260608-125236.csv` |

**Warm check before run:** `cxr-ops-lab/scripts/16-k8-stack-verify.sh` → `warmed: true`, **:8081** HTTP 200.

## Follow-up

**LOAD-004** — raise HPA caps (analyzer **8**, UI **5**) + multi-node kind; rerun same ramp. See [../LOAD-004-capacity-expanded.md](../LOAD-004-capacity-expanded.md).

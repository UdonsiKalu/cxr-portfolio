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

## kind vs Docker Desktop (comparison)

| | kind (2026-06-07) | Docker Desktop (2026-06-08) |
|---|-------------------|----------------------------|
| Context | `kind-cxr-lab` | `docker-desktop` |
| HPA caps | analyzer **4**, UI **3** | analyzer **8**, UI **5** |
| Peak users | ~**195** | **200** |
| Peak RPS | ~**20** | ~**50** (plot) / ~**33** (Locust UI) |
| Analyzer at peak | **4/4**, **309%/70%** | **8/8**, **330%/70%** |
| UI at peak | **3/3** | **5/5** |
| Failures | ~**0.43 fail/s** | ~**0**/s |
| Scheduling pressure | **1 Pending**, restarts | **0 Pending** (all Running) |
| Node CPU (plot) | n/a | ~**25%** at peak — pod cap not host |

**Conclusion:** Both runs proved HPA autoscaling and beat LOAD-002 RPS. Desktop with raised caps reached **~2.5×** kind peak RPS with **0** failures; bottleneck shifted from Pending pods to **HPA maxReplicas**.

## Follow-up

- **GITOPS-001** — Argo CD on Desktop; Git as source of truth ([kubernetes-deploy](../../kubernetes-deploy/))
- Archived kind LOAD-004: [../../archive/](../../archive/)

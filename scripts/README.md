# Script registry

<!-- portfolio -->

Index of **automation used in CXR investigations**. Scripts stay in place — this file only links and documents them.

**Convention:** Investigation-specific scripts live under `investigations/<name>/`. Shared portfolio helpers live under `scripts/`. Bootcamp deploy/load scripts live in **`cxr-ops-lab`** (sibling repo on disk).

---

## Portfolio — shared helpers

| Script | Location | Purpose | Inputs | Outputs | Calls | Investigation(s) |
|--------|----------|---------|--------|---------|-------|-------------------|
| `start-lab-notebook.sh` | [start-lab-notebook.sh](./start-lab-notebook.sh) | Optional JupyterLab on `:8888` | `pip install jupyterlab` | Browser UI | `jupyter lab` | Optional |
| `sync-investigation-notebooks.py` | [sync-investigation-notebooks.py](./sync-investigation-notebooks.py) | Legacy: rebuild notebooks from markdown | Python 3 | `*/notebook.ipynb` | — | Optional / archived nav |
| `capture-ci-k8-screenshots.sh` | [capture-ci-k8-screenshots.sh](./capture-ci-k8-screenshots.sh) | Regenerate CI/K8 evidence PNGs | `gh` auth, `:8081` up, Chrome headless | PNGs in `investigations/*/screenshots/` | `kubectl`, `helm`, `gh run list` | [CI-001](../investigations/ci-pipeline/), [K8-001](../archive/old-investigations/kubernetes-deploy/) |

---

## Portfolio — LOAD / PERF

| Script | Location | Purpose | Inputs | Outputs | Calls | Investigation(s) |
|--------|----------|---------|--------|---------|-------|-------------------|
| `run-capacity-sweep.sh` | [../archive/old-investigations/single-analyzer-capacity/run-capacity-sweep.sh](../archive/old-investigations/single-analyzer-capacity/run-capacity-sweep.sh) | Headless Locust capacity sweep 1→15 | `CXR_CAPACITY_USERS`, warm `:8251` | CSV in `results/` | `locustfile-analyze-only.py` | LOAD-001 |
| `run-capacity-locust-gui.sh` | [../archive/old-investigations/single-analyzer-capacity/run-capacity-locust-gui.sh](../archive/old-investigations/single-analyzer-capacity/run-capacity-locust-gui.sh) | Locust GUI staged ramp 1→15 | `:8089` or `CXR_LOCUST_WEB_PORT` | Charts screenshot | `locustfile-staged-gui.py` | LOAD-001 |
| `locustfile-analyze-only.py` | [../archive/old-investigations/single-analyzer-capacity/locustfile-analyze-only.py](../archive/old-investigations/single-analyzer-capacity/locustfile-analyze-only.py) | POST-only analyze load | Target URL `:8251` | Locust stats | — | LOAD-001 |
| `locustfile-staged-gui.py` | [../archive/old-investigations/single-analyzer-capacity/locustfile-staged-gui.py](../archive/old-investigations/single-analyzer-capacity/locustfile-staged-gui.py) | `LoadTestShape` staged users | Env tier list | Locust stats | — | LOAD-001, LOAD-002 |
| `run-saturation-sweep.sh` | [../archive/old-investigations/analyzer-saturation/run-saturation-sweep.sh](../archive/old-investigations/analyzer-saturation/run-saturation-sweep.sh) | Headless 15→35 saturation | `CXR_CAPACITY_*` | `results/saturation-sweep.csv` | `locustfile-staged-gui.py` | LOAD-002 |
| `run-saturation-locust-gui.sh` | [../archive/old-investigations/analyzer-saturation/run-saturation-locust-gui.sh](../archive/old-investigations/analyzer-saturation/run-saturation-locust-gui.sh) | GUI staged 15→35 | `:8090` default | Charts PNG | `run-capacity-locust-gui.sh` | LOAD-002 |
| `run-saturation-ramp-until-break-gui.sh` | [../archive/old-investigations/analyzer-saturation/run-saturation-ramp-until-break-gui.sh](../archive/old-investigations/analyzer-saturation/run-saturation-ramp-until-break-gui.sh) | Continuous ramp until stop | `CXR_RAMP_MAX_USERS` | Charts PNG | `locustfile-ramp-continuous.py` | LOAD-002 |
| `locustfile-ramp-continuous.py` | [../archive/old-investigations/analyzer-saturation/locustfile-ramp-continuous.py](../archive/old-investigations/analyzer-saturation/locustfile-ramp-continuous.py) | Continuous user ramp shape | Max users/duration env | Locust stats | — | LOAD-002 |

---

## Portfolio — REL / CHAOS / DEP

| Script | Location | Purpose | Inputs | Outputs | Calls | Investigation(s) |
|--------|----------|---------|--------|---------|-------|-------------------|
| `run-kill-analyzer-chaos.sh` | [../archive/old-investigations/kill-analyzer-under-traffic/run-kill-analyzer-chaos.sh](../archive/old-investigations/kill-analyzer-under-traffic/run-kill-analyzer-chaos.sh) | Automated CHAOS-001 timeline | `:8766` warm, Locust 5 users | `results/kill-chaos-*` | `kill-analyzer.sh`, `restart-analyzer-wait-warm.sh`, `locustfile-chaos-steady.py` | CHAOS-001 |
| `run-chaos-locust-gui.sh` | [../archive/old-investigations/kill-analyzer-under-traffic/run-chaos-locust-gui.sh](../archive/old-investigations/kill-analyzer-under-traffic/run-chaos-locust-gui.sh) | GUI chaos run for screenshots | Locust `:8089` | Charts PNG | `locustfile-chaos-steady.py` | CHAOS-001 |
| `kill-analyzer.sh` | [../archive/old-investigations/kill-analyzer-under-traffic/kill-analyzer.sh](../archive/old-investigations/kill-analyzer-under-traffic/kill-analyzer.sh) | Kill `:8766` analyzer | Running analyzer | Process stopped | `fuser -k 8766/tcp` | CHAOS-001 |
| `restart-analyzer-wait-warm.sh` | [../archive/old-investigations/kill-analyzer-under-traffic/restart-analyzer-wait-warm.sh](../archive/old-investigations/kill-analyzer-under-traffic/restart-analyzer-wait-warm.sh) | Restart analyzer until warmed | `start_analyzer_service.sh` on PATH | `/health` warmed | — | CHAOS-001 |
| `run-qdrant-outage-check.sh` | [../archive/old-investigations/qdrant-outage/run-qdrant-outage-check.sh](../archive/old-investigations/qdrant-outage/run-qdrant-outage-check.sh) | Qdrant up/down analyze checks | Docker Qdrant `:6333`, `:8251` | stdout summary | `curl`, analyzer restart | DEP-001 |

---

## External — cxr-ops-lab (not in this repo)

Paths relative to **`~/staging/cxr-ops-lab/`** on the author machine. Clone separately: https://github.com/UdonsiKalu/cxr-ops-lab

| Script | Purpose | Inputs | Outputs | Calls | Investigation(s) |
|--------|---------|--------|---------|-------|-------------------|
| `scripts/cxr-dev-stack.sh` | `cxr up/down/status` daily stack | — | `:8251`, `:8766`, Jaeger, Locust | observe scripts | Most investigations |
| `scripts/07-observe-up.sh` | Jaeger/Prometheus/Grafana stack | Docker | `:16686`, `:4318` | compose | OTEL-001, PERF-004 |
| `scripts/22-load-locust.sh` | Start Locust `:8089` | `CXR_LOAD_URL` | Locust UI | — | LOAD-* |
| `scripts/03-k8-up.sh` | UI-only kind deploy | kind, Helm | `:8081` UI shell | `01-kind`, `02-build-and-load`, `05-helm-install` | K8-001 (UI-only) |
| `scripts/03-k8-stack-up.sh` | Full stack UI + analyzer + HPA | kind, Docker build | `:8081`, in-cluster analyze | `06-helm-install-stack`, `09-metrics-server` | K8-001 stack |
| `scripts/06-helm-install-stack.sh` | Deploy analyzer + UI + HPA | Helm charts | K8 resources | metrics-server | K8-001 stack |
| `scripts/02-build-analyzer-and-load.sh` | Build `cxr-analyzer:local` | `claim_analysis_tools` | kind image load | `docker build` | K8-001 stack |

---

## External — application repos

| Item | Location | Purpose | Investigation(s) |
|------|----------|---------|-------------------|
| `.github/workflows/ci.yml` | `cxr-ui-rehearsal` | SW.6/6a/7 CI pipeline | CI-001 |
| `start_analyzer_service.sh` | `cxrlabs-dev/claim_analysis_tools/scripts/` | Warm analyzer `:8766` | PERF-004, OTEL-001, all analyze paths |

---

## Adding a row

When a new investigation adds scripts:

1. Keep scripts in `investigations/<folder>/` (or `scripts/` if shared).
2. Add a row to the table above.
3. Link from the investigation README **Scripts used** section.
4. Document **Calls** so dependency chains stay traceable.

See [template-investigation.md](../investigations/template-investigation.md).

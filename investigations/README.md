# Investigations

<!-- portfolio -->

Each **folder** is one question we ran (or will run) on the local CXR stack. Synthetic data, dev environment only.

> **Open notebooks, not markdown:** use **`README.ipynb`** (this index), **`00-navigation.ipynb`**, or **`lab-navigation.html`**. Plain `.md` files do not show clickable links in Cursor.

**New investigation:** copy `template-investigation.ipynb` → `<your-study>/notebook.ipynb`  
**Refresh all notebooks after editing markdown sources:** `python3 scripts/sync-investigation-notebooks.py`  
**Scripts:** `../scripts/README.md` (registry only)

---

## How to work

```bash
cd ~/staging/cxr-portfolio
./scripts/start-lab-notebook.sh
# browser → http://127.0.0.1:8888/lab
```

1. Open **`00-navigation.ipynb`** → **Shift+Enter** on first cell → click any study  
2. Or open **`lab-navigation.html`** in Chrome/Firefox (no Jupyter needed)  
3. Edit **`notebook.ipynb`** in each folder — add code cells, run commands with `!`

**`.md` files** remain for GitHub rendering only. Edit the notebook for daily work; re-run sync script if you need to refresh notebooks from README sources.

> **Locust p95** (aggregate under load) ≠ **Jaeger** single-trace duration. Report both separately.

---

## Completed (open as notebook)

| Investigation | Notebook |
|---------------|----------|
| Claim analysis latency | `latency-investigation/notebook.ipynb` |
| Locust load baseline | `load-testing/notebook.ipynb` |
| Missing spans / trace profile | `missing-spans/notebook.ipynb` |
| Postmortems | `postmortems/notebook.ipynb` |
| Cold vs warm analyzer (PERF-004) | `cold-vs-warm-analyzer/notebook.ipynb` |
| Single analyzer capacity (LOAD-001) | `single-analyzer-capacity/notebook.ipynb` |
| Analyzer saturation (LOAD-002) | `analyzer-saturation/notebook.ipynb` |
| Kill analyzer under traffic (CHAOS-001) | `kill-analyzer-under-traffic/notebook.ipynb` |
| Qdrant outage (DEP-001) | `qdrant-outage/notebook.ipynb` |
| End-to-end trace propagation (OTEL-001) | `trace-propagation/notebook.ipynb` |
| Bootcamp CI pipeline (CI-001) | `ci-pipeline/notebook.ipynb` |
| Kubernetes deploy (K8-001) | `kubernetes-deploy/notebook.ipynb` |
| Kubernetes analyzer saturation (LOAD-003) | `kubernetes-analyzer-saturation/README.md` |

---

## Run next (Phase 2)

| Investigation | Notebook |
|---------------|----------|
| Platform bootstrap | `planned/platform-bootstrap.ipynb` |
| Kubernetes migration / Argo | `planned/kubernetes-migration.ipynb` |
| Full backlog | `planned/notebook.ipynb` |

---

## Tools

### Jaeger {#jaeger}

http://127.0.0.1:16686 — filter **`cxr-ui-rehearsal`** → **`POST /api/claim-studio/analyze`**

### Locust {#locust}

http://127.0.0.1:8089 → `http://127.0.0.1:8251`. Start with `cxr up`.

### CI & Kubernetes {#ci-k8}

- **CI:** `ci-pipeline/notebook.ipynb`
- **K8:** `kubernetes-deploy/notebook.ipynb`

### Lab workflow {#lab-workflow}

`../architecture/diagrams/lab-workflow.mmd`

---

## Report template

Use **`template-investigation.ipynb`** only (not `.md`).

# Investigations

<!-- portfolio -->

Each **folder** is one question we ran (or will run) on the local CXR stack. Synthetic data, dev environment only.

**Studies index (start here):** [../studies/README.md](../studies/README.md)

> **Open notebooks, not markdown:** use **`README.ipynb`**, **`00-navigation.ipynb`**, or **`lab-navigation.html`**. Plain `.md` files do not show clickable links in Cursor.

**New investigation:** copy `template-investigation.ipynb` → `<your-study>/notebook.ipynb`  
**Refresh notebooks from markdown sources:** `python3 scripts/sync-investigation-notebooks.py`  
**Scripts:** [../scripts/README.md](../scripts/README.md)

Older completed folders live in [../archive/old-investigations/](../archive/old-investigations/README.md) — see [ARCHIVED.md](./ARCHIVED.md) for the path map.

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

> **Project changelog:** [../CHANGELOG.md](../CHANGELOG.md)

> **Locust p95** (aggregate under load) ≠ **Jaeger** single-trace duration. Report both separately.

---

## Active (happy path)

| Investigation | Entry |
|---------------|--------|
| Claim analysis latency | [latency-investigation/](./latency-investigation/) |
| Locust load baseline | [load-testing/](./load-testing/) |
| Cold vs warm analyzer | [cold-vs-warm-analyzer/](./cold-vs-warm-analyzer/) |
| Bootcamp CI pipeline | [ci-pipeline/](./ci-pipeline/) |
| Kubernetes analyzer saturation (LOAD-003+) | [kubernetes-analyzer-saturation/](./kubernetes-analyzer-saturation/) |
| Postmortems | [postmortems/](./postmortems/) |
| Planned backlog | [planned/](./planned/) |

---

## Archived (moved)

See [ARCHIVED.md](./ARCHIVED.md) and [archive/old-investigations/](../archive/old-investigations/).

---

## Tools

### Jaeger

http://127.0.0.1:16686 — filter **`cxr-ui-rehearsal`** → **`POST /api/claim-studio/analyze`**

### Locust

http://127.0.0.1:8089 → `http://127.0.0.1:8251`. Start with `cxr up`.

### CI & Kubernetes

- **CI:** [ci-pipeline/](./ci-pipeline/)
- **LOAD-003:** [kubernetes-analyzer-saturation/](./kubernetes-analyzer-saturation/)

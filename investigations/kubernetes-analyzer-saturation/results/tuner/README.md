# GATE-002 tuner results

Automated **KEDA + Helm grid search** under analyze-only saturation (OBS-comparable).

**Full study write-up:** [docs/GATE-002-keda-helm-grid-study.md](../../../../docs/GATE-002-keda-helm-grid-study.md) — first KEDA apply, 12 candidates, grid dimensions, pass/fail table @ 200 users.

## Canonical public evidence (2026-06-19)

**Stamp `080505`** — analyzer saturation profile; use for academic / reviewer citation.

| File | Purpose |
|------|---------|
| [tuner-summary-20260619-080505.json](tuner-summary-20260619-080505.json) | Winner (candidate 4) + full result |
| [result-c0-20260619-080505.json](result-c0-20260619-080505.json) … [result-c11-20260619-080505.json](result-c11-20260619-080505.json) | Per-candidate scores |

Earlier stamps (`072020` = lightweight mixed, others = dry runs) are local experiment history; not OBS-comparable unless noted in [failures index](../../../../failures/README.md).

Raw per-run CSVs under `run-*-c*/` are gitignored (large). JSON summaries and charts are kept for review.

**Config:** `cxr-ops-lab/tuner_config.yaml` · **Runner:** `cxr-ops-lab/scripts/k8-load-tuner.sh`

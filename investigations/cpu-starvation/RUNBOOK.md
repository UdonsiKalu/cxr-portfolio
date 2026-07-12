# CHAOS-004 — Runbook

Prereq: Claim Studio `:8251`, warm analyzer `:8766` (`warmed: true`).

## Folder layout

```text
cpu-starvation/
├── README.md                 # study entry
├── RESULTS.md                # plain English
├── RUNBOOK.md                # this file
├── run-cpu-starvation-check.sh
├── cpu_hog.py
├── results/                  # CSV, summary, JSON, logs
└── screenshots/              # terminal + htop PNGs
```

Same shape as `alerting-strategy/` and `database-unavailable/` — scripts stay at study root (not nested).

## Commands

```bash
cd cxr-portfolio   # or repo root

# Full lab
CXR_CPU_PROBES=2 CXR_CPU_WORKERS=48 ./investigations/cpu-starvation/run-cpu-starvation-check.sh

# Screenshot workflow
CXR_CPU_PROBES=2 CXR_CPU_WORKERS=48 ./investigations/cpu-starvation/run-cpu-starvation-check.sh --phase baseline
CXR_CPU_PROBES=2 CXR_CPU_WORKERS=48 ./investigations/cpu-starvation/run-cpu-starvation-check.sh --phase starved
# → htop screenshot (hog still running)
./investigations/cpu-starvation/run-cpu-starvation-check.sh --phase recovery

# Emergency stop hog only
./investigations/cpu-starvation/run-cpu-starvation-check.sh --phase stop-hog
```

## Outputs

All under `results/`: `cpu-starvation-probes.csv`, `*-summary.txt`, `*-timeline.log`, `analyze-*.json`.

## Notes

- Runner POSTs Analyze itself — **Locust not required**.
- Default workers = `nproc - 2`; override with `CXR_CPU_WORKERS`.
- After `--phase starved`, hog stays up until `recovery` or `stop-hog`.

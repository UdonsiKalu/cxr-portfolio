# Investigations layout — revert guide

**Tag:** `investigations-pre-flat` — snapshot before flat task-based folders (Jun 2026)  
**Earlier tag:** `investigations-pre-restructure` — taxonomy folder layout

## Undo flat layout

```bash
git checkout investigations-pre-flat -- investigations/
git commit -m "Revert investigations to pre-flat layout"
```

## Current layout (flat, task-named)

```
investigations/
├── README.md              # concepts + index
├── roadmap.md
├── latency-investigation/   ✅
├── load-testing/            ✅
├── missing-spans/           ✅
├── postmortems/             ✅ (3 markdown files)
├── cold-vs-warm-analyzer/
├── single-analyzer-capacity/
├── analyzer-saturation/
├── kill-analyzer-under-traffic/
├── qdrant-outage/
├── trace-propagation/
├── planned/                 # flat *.md backlog only
└── jaeger.md, locust.md, opentelemetry.md
```

No `performance/`, `load-capacity/`, `reliability/`, `chaos-experiments/`, `observability/`, `platform/`, or `cost/` category folders.

## Compare

```bash
git diff investigations-pre-flat..HEAD -- investigations/
```

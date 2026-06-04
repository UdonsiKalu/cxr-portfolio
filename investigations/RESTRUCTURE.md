# Investigations restructure — revert guide

**Branch:** `investigations-restructure`  
**Safety tag:** `investigations-pre-restructure` (annotated tag at the commit *before* this change)  
**Safety branch:** `investigations-pre-restructure` (same snapshot; optional checkout)

Push tag remotely: `git push origin refs/tags/investigations-pre-restructure`

## Undo completely (restore old layout)

From repo root:

```bash
git checkout investigations-pre-restructure -- investigations/
git commit -m "Revert investigations folder to pre-restructure layout"
```

Or reset the whole branch to the tag (destructive on this branch):

```bash
git reset --hard investigations-pre-restructure
```

## Compare old vs new

```bash
git diff investigations-pre-restructure..HEAD -- investigations/
```

## What changed

- **Phase 1** folders kept for active/completed evidence: `latency-investigation/`, `load-testing/`, `performance/PERF-004`, `load-capacity/LOAD-001|002`, `reliability/REL-001|003`, `chaos-experiments/CHAOS-001`, `observability/OBS-001|002`, `incidents/`
- **Phase 2** stubs moved to `planned/` as markdown files
- **`roadmap.md`** added for execution order
- **`platform/`** and **`cost/`** top-level categories removed (content in `planned/`)

## Merge to master

If the restructure looks good:

```bash
git checkout master
git merge investigations-restructure
git push origin master
git push origin investigations-pre-restructure  # optional: push tag for remote revert
```

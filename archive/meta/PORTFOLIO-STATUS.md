# Portfolio status (maintainers)

**Not part of the reviewer path.** Reviewers start at [docs/README.md](../../docs/README.md).

## Reviewer fast path (public)

| Item | Status |
|------|--------|
| [docs/README.md](../../docs/README.md) | Complete — reviewer hub |
| [docs/REVIEWER-GUIDE.md](../../docs/REVIEWER-GUIDE.md) | Complete — academic/technical checklist |
| [docs/history.md](../../docs/history.md) | Complete — curated development arc |
| [failures/README.md](../../failures/README.md) | Complete — failure index |
| [reliability/SLO.md](../../reliability/SLO.md) | Complete — SLI/SLO + gates |
| [archive/meta/my-impact.md](../meta/my-impact.md) | Complete |
| [investigations/latency-investigation/](../../investigations/latency-investigation/) | Complete |
| [GATE-002 tuner summary](../../investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-20260619-080505.json) | Complete |
| [Python import bottleneck postmortem](../../investigations/postmortems/python-import-bottleneck.md) | Complete |
| [ADR-004](../../architecture/adrs/ADR-004-long-running-analyzer.md) | Complete |
| [demo/RUN.md](../../demo/RUN.md) | Complete |

## Full outline

All paths from [STRUCTURE.md](./STRUCTURE.md) exist with **content**. Sections marked **Planned** in chaos/SLO alerting still need game-day evidence before claiming production-style reliability.

## When to go public

See [docs/GO-PUBLIC.md](../../docs/GO-PUBLIC.md). Summary:

- [x] Reviewer hub (`docs/`) with decisions / investigations / postmortems / failures indexes
- [x] GATE-002 summary in changelog + failures index
- [x] SLO document
- [ ] Commit and push pending local changes
- [ ] Reviewer fast path verified on a second machine (optional)
- [ ] C4 PNGs in `architecture/diagrams/` (optional)
- [ ] `gh repo edit --visibility public` + pin on profile
- [ ] Push `cxr-ops-lab` gate automation (optional, for reproduction)

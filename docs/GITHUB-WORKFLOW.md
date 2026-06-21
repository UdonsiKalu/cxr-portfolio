# GitHub workflow (portfolio repo)

How **cxr-portfolio** uses GitHub for honest DevOps portfolio work — planning, documenting, and publishing evidence. **Not** the CXR application codebase; runnable automation lives in **`cxr-ops-lab`** (when published).

---

## Project board

**Project:** [CXR Portfolio DevOps](https://github.com/users/UdonsiKalu/projects) (user project — link from GitHub **Projects** tab if URL differs)

| Column | Meaning |
|--------|---------|
| **Backlog** | Scoped, not started |
| **In Progress** | Lab work or drafting |
| **Testing** | Gate run, metrics, reproduce |
| **Documenting** | Writing investigation + CHANGELOG |
| **Done** | Merged to `master`; evidence linked |

---

## Milestones

| Milestone | Scope |
|-----------|--------|
| **Autoscaling & load gates** | LOAD-003, OBS-001, GATE-002, exporter metrics, ops-lab publish |
| *(add later)* **Observability** | OTEL, Jaeger, trace completeness |
| *(add later)* **Open source readiness** | LICENSE, ops-lab public, Pages |

---

## Issue → PR → evidence flow

```
GitHub Issue (LOAD/OBS/OPS-xxx)
    → branch
    → lab work (local cxr-ops-lab)
    → commit docs + evidence paths on cxr-portfolio
    → Pull Request (template: problem → result → decision)
    → portfolio-check CI
    → merge master
    → close issue; move Project card to Done
    → optional GitHub Release tag (portfolio-v0.x)
```

**Solo PRs are required** — even one person: PR = review checkpoint and audit trail.

---

## Labels (suggested)

| Label | Use |
|-------|-----|
| `documentation` | Docs, investigations, reviewer hub |
| `enhancement` | New investigation or gate feature |
| `investigation` | Active study (create in GitHub if missing) |
| `ops-lab` | Blocked on or tracks `cxr-ops-lab` publish |

---

## What runs in CI (this repo)

Workflow: [`.github/workflows/portfolio-check.yml`](../.github/workflows/portfolio-check.yml)

- Reject committed `.env` / credential-like paths  
- Validate tuner summary JSON parses  
- Assert reviewer hub files exist  

**Not in this repo:** Docker build, Trivy, Playwright, Helm — those belong in **`cxr-ops-lab`** when public.

---

## Branch protection (enable manually)

**Settings → Branches → Add rule for `master`:**

- [ ] Require a pull request before merging  
- [ ] Require status checks to pass (`portfolio-check`)  
- [ ] Do not allow bypassing (optional for solo — your choice)

---

## Releases (portfolio narrative tags)

| Tag | Meaning |
|-----|---------|
| `portfolio-v0.1` | Reviewer hub + LOAD-003 arc (baseline) |
| `portfolio-v0.2` | GATE-002 evidence + SLO + failures index |
| `portfolio-v0.3` | GitHub Projects + issue-driven workflow |

Release notes = excerpt from [CHANGELOG.md](../CHANGELOG.md), not product semver.

---

## GitHub Pages (later)

Optional: publish `docs/` + investigation index as a static site. Defer until advisor review cycle completes.

---

## Related

- [REVIEWER-GUIDE.md](REVIEWER-GUIDE.md) — external review path  
- [GO-PUBLIC.md](GO-PUBLIC.md) — visibility checklist  
- [cxr-ops-lab](https://github.com/UdonsiKalu/cxr-ops-lab) — future home for gate CI, GHCR, Helm validate (when public)

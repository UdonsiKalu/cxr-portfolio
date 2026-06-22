# GitHub workflow (portfolio repo)

How **cxr-portfolio** uses GitHub for honest DevOps portfolio work — planning, documenting, and publishing evidence. **Not** the CXR application codebase; runnable automation lives in **`cxr-ops-lab`** (when published).

---

## Project board

Create once in GitHub UI (requires `project` scope on `gh auth` for CLI):

1. **Profile → Projects → New project** → name: **CXR Portfolio DevOps**
2. **Link repository:** `UdonsiKalu/cxr-portfolio`
3. Set columns: **Backlog → In Progress → Testing → Documenting → Done**
4. Add open issues from [Issues](https://github.com/UdonsiKalu/cxr-portfolio/issues)

### Make the board public (reviewers)

GitHub Projects are **private by default**. To share the Kanban with recruiters or interviewers:

1. Open **https://github.com/users/UdonsiKalu/projects** (or **Profile → Projects** → **CXR Portfolio DevOps**).
2. Click **⋯** (project menu) → **Settings**.
3. Under **Visibility**, choose **Public** → confirm.

After publishing, link the project URL from [failures/README.md](../failures/README.md) and your portfolio README. CLI (after `gh auth refresh -h github.com -s project,read:project`):

```bash
gh project list --owner UdonsiKalu
# Note the project number, then:
gh project edit <NUMBER> --owner UdonsiKalu --visibility public
```

| Column | Meaning |
|--------|---------|
| **Backlog** | Scoped, not started |
| **In Progress** | Lab work or drafting |
| **Testing** | Gate run, metrics, reproduce |
| **Documenting** | Writing investigation + CHANGELOG |
| **Done** | Merged to `master`; evidence linked |

**Open issues (milestone: Autoscaling & load gates):**

| Issue | Title |
|-------|--------|
| [#2](https://github.com/UdonsiKalu/cxr-portfolio/issues/2) | OBS-002: Analyzer replica metrics in Grafana and gate CSV |
| [#25](https://github.com/UdonsiKalu/cxr-portfolio/issues/25) | PERF-008: Queue / backpressure KEDA A/B — PR [#26](https://github.com/UdonsiKalu/cxr-portfolio/pull/26) |
| [#3](https://github.com/UdonsiKalu/cxr-portfolio/issues/3) | OPS-001: Publish cxr-ops-lab load gate automation |
| [#4](https://github.com/UdonsiKalu/cxr-portfolio/issues/4) | DOC-003: GitHub Pages for reviewer hub (optional) |
| [#24](https://github.com/UdonsiKalu/cxr-portfolio/issues/24) | GIT-001: Argo / Git values drift |

**Backlog (milestone: Phase 2 — investigations backlog):** [#6–#23](https://github.com/UdonsiKalu/cxr-portfolio/issues?q=is%3Aissue+is%3Aopen+milestone%3A%22Phase+2+%E2%80%94+investigations+backlog%22) — imported from [investigations/planned/](../investigations/planned/README.md) (2026-06-21).

---

## Milestones

| Milestone | Scope |
|-----------|--------|
| **Autoscaling & load gates** | LOAD-003, OBS-001, GATE-002, exporter metrics, ops-lab publish, GIT-001 |
| **Phase 2 — investigations backlog** | All items in `investigations/planned/` → GitHub Issues #6–#23 |
| **PERF-008** | [Queue / backpressure autoscaling](../docs/PERF-008-queue-depth-autoscaling.md) — branch `feature/perf-008-queue-backpressure` |
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

# Going public — checklist

Steps to publish **`cxr-portfolio`** for academic advisors, reviewers, and your GitHub profile.

---

## Before `gh repo edit --visibility public`

### Content readiness

- [ ] [README.md](README.md) — reviewer entry point is accurate  
- [ ] [archive/reviewer/REVIEWER-GUIDE.md](REVIEWER-GUIDE.md) — checklist matches repo contents  
- [ ] [CHANGELOG.md](../CHANGELOG.md) — includes GATE-002 / latest milestones  
- [ ] [archive/reviewer/history.md](history.md) — curated arc current  
- [ ] [failures/README.md](../failures/README.md) — honest failure index  
- [ ] [reliability/SLO.md](../reliability/SLO.md) — SLO tiers documented  
- [ ] [archive/DISCLAIMER.md](../archive/DISCLAIMER.md) — synthetic data / not production  
- [ ] Tuner summary JSON committed: `investigations/kubernetes-analyzer-saturation/results/tuner/tuner-summary-*.json`  
- [ ] Key screenshots present under `investigations/*/screenshots/`  
- [ ] No secrets: `.env`, tokens, real PHI (see root `.gitignore`)

### Hygiene

- [ ] Remove or gitignore `.ipynb_checkpoints/`  
- [ ] Do not commit multi-GB CSV dumps — use `.gitignore` under `results/` (summaries + charts only)  
- [ ] Optional: second-machine check of [archive/demo/RUN.md](../archive/demo/RUN.md) reviewer path

### Companion repos (optional for reviewers)

Portfolio stands alone for **document review**. For reproduction, link from README:

| Repo | Public? | Notes |
|------|---------|-------|
| `cxr-portfolio` | **This repo** | Evidence + narrative |
| `cxr-ops-lab` | Recommended | Gates, Helm — push `feature/load-perf-automation` or merge first |
| `cxr-ui-rehearsal` | Optional | CI investigation references it |
| `cxrlabs-dev/claim_analysis_tools` | Optional | Analyzer source — may stay private |

---

## Publish commands

```bash
cd ~/staging/cxr-portfolio

# Review what will ship
git status
git diff --stat

# Stage reviewer structure + evidence (adjust paths as needed)
git add docs/ failures/ reliability/ CHANGELOG.md README.md
git add investigations/kubernetes-analyzer-saturation/results/.gitignore
git add investigations/kubernetes-analyzer-saturation/results/tuner/*.json

git commit -m "Add reviewer hub, failures index, SLO doc, and GATE-002 evidence for public portfolio."

git push origin master

# Make public (requires gh auth)
gh repo edit UdonsiKalu/cxr-portfolio --visibility public

# Pin on your GitHub profile: Settings → Profile → Pin repository
```

---

## After going public

1. Add to profile README (optional): one paragraph + link to [README.md](README.md)  
2. Share **15-minute path**: [my-impact.md](../archive/meta/my-impact.md) → [history.md](history.md) → ADR-004  
3. Share **full review path**: [REVIEWER-GUIDE.md](REVIEWER-GUIDE.md)  
4. Update [PORTFOLIO-STATUS.md](../archive/meta/PORTFOLIO-STATUS.md) — check off go-public items  

---

## What reviewers should be told

- **Synthetic data only** — no real patient or payer information  
- **Lab environment** — Docker Desktop K8, not production HA  
- **GATE-002 pass** = capacity gate under synthetic analyze saturation, not prod SLO sign-off  
- **Companion code** in other repos is optional for document-only review  

---

## Maintainer map

| Audience | Entry URL |
|----------|-----------|
| Reviewers / advisors | [README.md](README.md) |
| Quick impact summary | [archive/meta/my-impact.md](../archive/meta/my-impact.md) |
| Full changelog | [CHANGELOG.md](../CHANGELOG.md) |
| Maintainers | [archive/meta/PORTFOLIO-STATUS.md](../archive/meta/PORTFOLIO-STATUS.md) |

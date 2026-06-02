# CI/CD

## Canonical workflow

**Rehearsal UI** (`cxr-ui-prune-rehearsal/cxr-ui`) carries bootcamp CI:

- SW.6 build
- SW.6a Playwright smoke
- SW.7 Trivy policy scan

File: `.github/workflows/ci.yml` in the UI repo (when published).

## Portfolio scope

This repo documents CI **evidence** and architecture; workflow YAML lives with application code to avoid duplication.

## Related evidence

- `cxr-ops-lab/evidence/SW7-trivy-verify.md` (companion monorepo)

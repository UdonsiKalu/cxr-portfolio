# CI/CD

## Canonical workflow

**Rehearsal UI** (`cxr-ui-rehearsal`) carries bootcamp CI:

- SW.6 build
- SW.6a Playwright smoke
- SW.7 Docker build + Trivy policy scan

File: `.github/workflows/ci.yml` in the UI repo.

**Portfolio investigation:** [investigations/ci-pipeline/](../investigations/ci-pipeline/) (CI-001)

## CD / GitOps (separate)

- **Not** in the CI workflow — no auto-deploy to **:8251** or **:8081**
- SW.8 Argo CD in **`cxr-ops-lab`** (`13-argo-install.sh`, **:8083**)
- **Portfolio investigation:** [archive/old-investigations/kubernetes-deploy/](../archive/old-investigations/kubernetes-deploy/) (K8-001)

## Related evidence

- `cxr-ops-lab/evidence/SW7-trivy-verify.md`
- `cxr-ops-lab/evidence/SW3-k8-evidence.md`
- `cxr-ui-rehearsal` Actions: https://github.com/UdonsiKalu/cxr-ui-rehearsal/actions

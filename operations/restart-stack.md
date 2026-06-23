# Restart stack — `cxr` dev CLI

## One command (recommended)

From a machine with the CXR staging tree:

```bash
~/staging/cxr-dev.sh up      # Jaeger + analyzer :8766 + UI :8251 + Locust :8089
~/staging/cxr-dev.sh status
~/staging/cxr-dev.sh down
~/staging/cxr-dev.sh down --observe-down   # also stop Docker observe
```

Optional alias:

```bash
alias cxr='~/staging/cxr-dev.sh'
```

## URLs after `up`

| URL | Purpose |
|-----|---------|
| http://127.0.0.1:8251/claim-studio | Claim Studio |
| http://127.0.0.1:16686 | Jaeger |
| http://127.0.0.1:8089 | Locust |

## Logs

- `/tmp/cxr-analyzer-service.log`
- `/tmp/cxr-rehearsal-8251.log`
- `/tmp/cxr-locust-8089.log`

## Implementation

Script: `cxr-ops-lab/scripts/cxr-dev-stack.sh` (wrapper at `staging/cxr-dev.sh`).

See [archive/demo/RUN.md](../archive/demo/RUN.md#troubleshooting) for slow analyze and missing traces.

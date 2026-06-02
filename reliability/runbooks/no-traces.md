# Runbook — no traces in Jaeger

## Checks

1. http://127.0.0.1:16686 loads?
2. `OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318` on Next.js process?
3. Generate traffic (analyze POST, not only GET pages).
4. Search **Last 1 hour** · Service `cxr-ui-rehearsal`.

## Fixes

| Cause | Action |
|-------|--------|
| Observe down | `cxr up` or `07-observe-up.sh` |
| Docker hung | Restart Docker Desktop; `cxr down --observe-down` then `cxr up` |
| Wrong service filter | Also try `cxr-analyzer-service` |
| Startup trace missing | Restart analyzer; look for `analyzer_service.startup` |

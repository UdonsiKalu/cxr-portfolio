# Runbook — slow analyze API

## Symptom

`POST /api/claim-studio/analyze` > 5s when you expect **~1.5s** Locust p95 or **~154–708ms** on a warm Jaeger trace.

## Checks

1. `curl http://127.0.0.1:8766/health` → `"warmed":"true"`?
2. Response JSON includes `"analyzer_mode":"http"` (not subprocess fallback)?
3. Jaeger: is time in `analyzer_service.startup` (restarted recently) vs `context_builder`?

## Fixes

| Cause | Action |
|-------|--------|
| Analyzer down | `cxr up` |
| Subprocess fallback | Set `ANALYZER_URL` in `.env.local`; restart UI |
| Cold analyzer | Wait for startup trace to finish (~7s once) |
| Qdrant down | WARN only unless retrieval required |

See [INC-003](../incidents/INC-003-python-import-bottleneck/postmortem.md).

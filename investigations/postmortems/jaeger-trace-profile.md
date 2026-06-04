# INC-002 — Jaeger trace UX / minimal profile regression

**Severity:** Medium (investigation friction)  
**Status:** Resolved  
**Component:** OpenTelemetry trace profiles

## Summary

After enabling tracing, Jaeger showed many Operations and traces. An attempt to simplify via **`CXR_TRACE_PROFILE=minimal`** made UX **worse**: **47** Operations on some services, only **~7 spans** per trace, lost consistent view of `context_builder` and imports.

## Root cause

Minimal profile collapsed stages into events but increased confusing Operation names; users could not find **`analyzer_service.startup`** without analyzer restart + flush.

## Resolution

- Reverted default to **`detailed`** profile.
- Added `flush_tracing()` after analyzer lifespan.
- Documented which Jaeger Service/Operation to use for Python vs Node.

## Lessons

- Fewer span names ≠ clearer observability.
- Startup traces require explicit export + analyzer restart to appear in Operation dropdown.

See [investigations README — Jaeger](../README.md#jaeger).

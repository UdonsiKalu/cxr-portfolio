# Missing spans / trace profile UX

**Status:** Completed

`CXR_TRACE_PROFILE=minimal` reduced useful spans (~7 vs ~21). Default restored to **detailed**; `flush_tracing()` added after analyzer lifespan.

See [jaeger.md — trace profiles](../jaeger.md#trace-profiles) and [postmortem: jaeger trace profile](../postmortems/jaeger-trace-profile.md).

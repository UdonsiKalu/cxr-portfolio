# CHAOS-002 — Network latency

**Status:** Planned (Phase 2)

## Question

How does injected latency between UI (:8251) and analyzer (:8766) affect Locust p95 and Jaeger traces?

## Method (draft)

Inject latency (`tc`, toxiproxy, or compose network shaping) between UI and analyzer.

## Record results in

`cxr-ops-lab/evidence/` and promote to active folder when run.

# Engineering philosophy

## Show the implementation

Skills on a profile are claims. **Traces, ADRs, load tests, and runbooks** are proof. This portfolio exists because CXR work produced measurable outcomes—not because a checklist of tools was memorized.

## Measure before optimizing

The **~10s vs ~1.5s** story only makes sense with Jaeger and Locust together. Optimizing `context_builder` without fixing process architecture would have been a waste.

## Operability is a feature

If only one engineer can start the stack from memory, the system is not ready for collaboration. **`cxr up`** is part of the product of engineering.

## Honest scope

Bootcamp labs (Kafka, Vault, …) are **learning infrastructure**, not implied production deployments. Documents say when something is scaffold vs shipped.

## Default to detailed observability

When trace profiles trade away debuggability for aesthetics, **reject the trade** unless SLO dashboards truly require it (they did not, here).

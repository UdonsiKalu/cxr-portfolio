# CHAOS-002 — Network latency

**Status:** Done → [../network-latency-injection/](../network-latency-injection/)

## Question

How does injected latency on the warm analyzer HTTP hop affect Analyze wall time and success?

## Method

Delay proxy `:8767` → `:8766`; tiers 0 / 100 / 500 / 2000 ms; curl Analyze through proxy.

## Results

See [RESULTS.md](../network-latency-injection/RESULTS.md). Soft degradation (always HTTP 200); delay ≈ additive.

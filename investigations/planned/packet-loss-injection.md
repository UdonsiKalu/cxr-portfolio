# CHAOS-003 — Packet loss

**Status:** Planned (Phase 2) · issue [#16](https://github.com/UdonsiKalu/cxr-portfolio/issues/16)

## Question

How does packet loss on the warm analyzer HTTP hop affect Analyze success rate and tail latency?

## Method (draft)

Reuse the CHAOS-002 delay proxy ([network-latency-injection/](../network-latency-injection/)) with a **loss %** toxic instead of (or in addition to) delay. Tiers e.g. 0% / 1% / 5% / 10%; probe `POST /analyze` through `:8767`; CSV + chart like CHAOS-002.

## Results

Not yet run.

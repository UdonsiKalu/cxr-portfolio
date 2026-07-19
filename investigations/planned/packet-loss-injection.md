# CHAOS-003 — Packet loss

**Status:** Done → [../packet-loss-injection/](../packet-loss-injection/)

## Question

How does packet loss on the warm analyzer HTTP hop affect Analyze success rate and latency?

## Method

Reuse CHAOS-002 `delay_proxy.py` with `loss_pct`; tiers 0/1/5/10/20%; 20 probes each.

## Results

See [RESULTS.md](../packet-loss-injection/RESULTS.md). Loss causes drops (hard per-request); OK calls stay ~60 ms.

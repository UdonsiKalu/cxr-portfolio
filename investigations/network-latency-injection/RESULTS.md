# The story — CHAOS-002 network latency

**Read this first.** Issue [#15](https://github.com/UdonsiKalu/cxr-portfolio/issues/15).

---

## In one paragraph

We wondered: if the link to the warm analyzer is slow (not dead), does Analyze still work? We put a small delay proxy in front of `:8766`, added 100 ms / 500 ms / 2000 ms of sleep before each request, and timed Analyze. It **always succeeded** (HTTP 200). The extra wait showed up almost **exactly** in the wall-clock time — about 60 ms baseline became about 2.05 s with a 2 s inject. So network delay hurts **speed**, not **availability** — similar to CPU starvation, different from SQL down.

---

## What we did

1. Started a warm analyzer on `:8766`.
2. Started `delay_proxy.py` on `:8767` forwarding to `:8766`.
3. **Baseline** — proxy delay 0 → Analyze ~**64 ms** median.
4. **Injected** 100 / 500 / 2000 ms — medians ~**163 / 560 / 2055 ms**.
5. **Recovery** — delay back to 0 → ~**63 ms**.
6. Charted the tiers.

We probed the **warm HTTP** `/analyze` hop on purpose. That is the path a UI hits when wired to `ANALYZER_URL`. Locust was not used.

---

## What the numbers say

| When | Injected | How long | Worked? |
|------|----------|----------|---------|
| Baseline | 0 | ~64 ms | Yes (200) |
| +100 ms | 100 | ~163 ms | Yes (200) |
| +500 ms | 500 | ~560 ms | Yes (200) |
| +2000 ms | 2000 | ~2055 ms | Yes (200) |
| Recovery | 0 | ~63 ms | Yes (200) |

---

## What this means for ops

- Extra RTT → **slower claims**, not “Analyze is dead.”
- Page vs ticket: treat like soft degradation (see [alerting](../alerting-strategy/)) unless an SLO breach is sustained.
- Next chaos twin: [packet loss](../planned/packet-loss-injection.md) (#16) — same proxy idea, loss % instead of delay.

---

## Files

| What | Where |
|------|--------|
| This story | [RESULTS.md](./RESULTS.md) |
| How to re-run | [RUNBOOK.md](./RUNBOOK.md) |
| Chart | [screenshots/latency-by-tier.png](./screenshots/latency-by-tier.png) |
| Exact times | [results/network-latency-probes.csv](./results/network-latency-probes.csv) |

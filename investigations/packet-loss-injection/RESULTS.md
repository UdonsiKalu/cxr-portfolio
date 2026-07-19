# The story — CHAOS-003 packet loss

**Read this first.** Issue [#16](https://github.com/UdonsiKalu/cxr-portfolio/issues/16).

---

## In one paragraph

We wondered: if some packets to the warm analyzer never arrive, does Analyze get slower or just fail? We reused the CHAOS-002 proxy and randomly **dropped** a percentage of requests before they reached `:8766`. At **0–1%** loss, all 20 probes still succeeded. At **5–10%**, about **95%** succeeded. At **20%**, success fell to **85%**. When a call got through, it still finished in ~60 ms — so loss causes **failed requests**, not the soft slowdown we saw with pure latency.

---

## What we did

1. Warm analyzer on `:8766`.
2. Proxy on `:8767` with configurable `loss_pct`.
3. Ran 20 Analyze probes at 0 / 1 / 5 / 10 / 20% loss, then recovery at 0%.
4. Charted success rate vs tier.

---

## Ops takeaway

- Packet loss → **errors / empty replies** (hard for that request).
- Network latency (CHAOS-002) → **slower but still 200**.
- Different alert posture: sustained loss looks more like a ticket; mild RTT looks like a page/SLO watch.

---

## Files

| What | Where |
|------|--------|
| This story | [RESULTS.md](./RESULTS.md) |
| Chart | [screenshots/success-by-loss-tier.png](./screenshots/success-by-loss-tier.png) |
| Exact probes | [results/packet-loss-probes.csv](./results/packet-loss-probes.csv) |

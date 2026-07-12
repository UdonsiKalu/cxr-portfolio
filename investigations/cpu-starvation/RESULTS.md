# The story — CHAOS-004 CPU starvation

**Read this first.** Simple language. Issue [#17](https://github.com/UdonsiKalu/cxr-portfolio/issues/17).

The chart PNG is **one** picture — not the whole study. The write-up + numbers live here and under `results/`.

---

## In one paragraph

We wondered: if the computer’s CPUs are busy with other work, does claim Analyze still work? We measured Analyze when the machine was quiet, then while we burned most CPUs on purpose, then after we stopped burning them. Analyze **always succeeded** (HTTP 200). It just got **about 58% slower** while the CPUs were busy, then sped back up when we stopped. So CPU overload hurts **speed**, not **availability** — different from SQL going down (which returns errors).

---

## What we did (the process)

1. **Started the normal lab** — Claim Studio on `:8251`, warm analyzer on `:8766`.
2. **Baseline** — ran Analyze a couple of times with a quiet machine. Took about **13.5 seconds** each. That is our “normal.”
3. **Starved** — started many busy CPU workers (48 on this host) so the machine was under heavy load. Ran Analyze again. Still succeeded, but took about **21.3 seconds** (~half again as long).
4. **Recovery** — stopped the CPU workers. Ran Analyze again. Back to about **14 seconds** — close to normal.
5. **Wrote it down** — times in a CSV, a short summary file, and a bar chart.

We did **not** need Locust, Kubernetes, or Jaeger for this story.

---

## What the numbers say

| When | How long Analyze took | Did it work? |
|------|------------------------|--------------|
| Quiet CPU (baseline) | ~13.5 s | Yes (200) |
| Busy CPU (starved) | ~21.3 s | Yes (200) |
| After we stopped (recovery) | ~14 s | Yes (200) |

---

## What documents we have (not just the PNG)

| What | Where | Role |
|------|--------|------|
| **This story** | [RESULTS.md](./RESULTS.md) (this file) | Plain English — start here |
| **Study front page** | [README.md](./README.md) | Short table + how to re-run |
| **How to re-run** | [RUNBOOK.md](./RUNBOOK.md) | Commands |
| **Bar chart** | [screenshots/latency-by-phase.png](./screenshots/latency-by-phase.png) | Picture of the three phases |
| **Exact times** | [results/cpu-starvation-probes.csv](./results/cpu-starvation-probes.csv) | Spreadsheet of each probe |
| **Medians** | [results/cpu-starvation-summary.txt](./results/cpu-starvation-summary.txt) | One-page number dump |
| **Log** | [results/cpu-starvation-timeline.log](./results/cpu-starvation-timeline.log) | What ran when |
| **Raw API bodies** | `results/analyze-*.json` | Full Analyze responses (optional; not needed to understand the story) |

Optional later: an `htop` screenshot showing CPUs pegged. Nice, not required — the chart + CSV already prove the slowdown.

---

## What this means for ops

- CPU starvation → **slow claims**, not “Analyze is dead.”
- SQL down (REL-004) → **errors** — different problem, different alert.
- Don’t page someone only because Analyze took 20 seconds if the analyzer is healthy and the database is up (see [alerting study](../alerting-strategy/)).

---

## Bottom line

Busy CPUs make Analyze **slower but still working**. When load ends, speed comes back. The PNG shows that; the CSV proves the numbers; this page tells the story.

# Study — Game day (combined failures)

| | |
|---|---|
| **Status** | Complete (2026-07-12) |
| **ID** | Game day / #18 |
| **Audience** | Portfolio / technical interviewer |
| **Learner path** | Start at [LEARNER.md](./LEARNER.md) if new to DevOps |

---

## Question

In a local CXR stack, which injected failures make Claim Studio **Analyze** a hard error (HTTP 5xx), and which leave Analyze available (HTTP 200) with only degraded health or latency?

## Hypothesis

- SQL unreachable → **hard** fail (matches REL-004).
- Ollama down / CPU contention → **soft** (matches REL-002 / CHAOS-004).
- Analyzer process kill → health fails; Analyze may still succeed if a fallback path exists.

## Method

Sequential scenarios with full recovery between each (`run-game-day.sh`):

1. **S0** baseline probes (health, SQL TCP, Ollama, Analyze, OBS-003 one-shot)
2. **S1** kill warm analyzer `:8766` → probe → restart warm analyzer
3. **S2** iptables REJECT `:1433` → probe → unblock
4. **S3** `systemctl stop ollama` → probe → start
5. **S4** CPU hog (CHAOS-004 helpers) → probe → stop hog
6. **S5** final healthy probe

Evidence: CSV timeline, alert-probe text captures, Chrome-rendered PNGs via `render-game-day-screenshots.py`.

## Results (mid-outage)

| Scenario | A2 health | A3 SQL | Ollama | A1 Analyze |
|----------|-----------|--------|--------|------------|
| S0 baseline | 200 | open | up | **200** ~15.0 s |
| S1 analyzer down | fail | open | up | **200** ~14.1 s (fallback) |
| S2 SQL down | 200 | closed | up | **500** ~23.7 s |
| S3 Ollama down | 200 | open | down | **200** ~13.7 s |
| S4 CPU hog | 200 | open | up | **200** ~15.6 s |
| S5 final | 200 | open | up | **200** ~14.2 s |

## Decision / takeaways

1. Treat **SQL loss** as page-class (hard Analyze failure).
2. Treat **Ollama / CPU** as ticket/watch (soft).
3. **Analyzer down** is still an ops incident even when Analyze returns 200 — monitor **health**, not only user HTTP codes.
4. Game day is the integration proof linking REL-002, REL-004, CHAOS-004, and OBS-003 probes.

## Artifacts

- [LEARNER.md](./LEARNER.md) — beginner story  
- [RESULTS.md](./RESULTS.md) — short narrative  
- [RUNBOOK.md](./RUNBOOK.md) — how to re-run  
- [screenshots/](./screenshots/) — pictorial evidence  
- [results/game-day-probes.csv](./results/game-day-probes.csv) — raw rows  

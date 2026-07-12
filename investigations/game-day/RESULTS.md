# The story — Game day (short)

Readable walkthrough: [LEARNER.md](./LEARNER.md) · Formal study: [STUDY.md](./STUDY.md)

Issue [#18](https://github.com/UdonsiKalu/cxr-portfolio/issues/18).

---

## In one paragraph

Sequential failure drill with recovery between scenarios. **SQL down** → Analyze **HTTP 500** (hard). **Ollama down** and **CPU contention** → Analyze **200** (soft). **Analyzer killed** → health fails while Analyze can still return **200** via fallback — monitor health, not only user-facing success.

---

## Results table

| # | What we broke | Analyze mid-outage | Hard / soft |
|---|---------------|--------------------|-------------|
| S0 | Nothing | **200** ~15 s | — |
| S1 | Analyzer `:8766` | **200** ~14 s | Soft for request; health failed |
| S2 | SQL `:1433` | **500** ~24 s | **Hard** |
| S3 | Ollama | **200** ~14 s | Soft |
| S4 | CPU hog | **200** ~15.6 s | Soft |
| S5 | Final | **200** ~14 s | recovered |

---

## Pictures

![Overview](screenshots/00-overview-matrix.png)

Full set: [screenshots/](./screenshots/) · Numbers: [results/game-day-probes.csv](./results/game-day-probes.csv)

Re-run: [RUNBOOK.md](./RUNBOOK.md)

# The story — Game day (combined failures)

**Read this first.** Issue [#18](https://github.com/UdonsiKalu/cxr-portfolio/issues/18).

We ran a fire drill: break one thing at a time, watch Analyze + health/SQL/Ollama checks, then fix it before the next break. Goal: see which failures are **hard** (Analyze dies) vs **soft** (Analyze still works).

---

## In one paragraph

Baseline was healthy (~15 s Analyze, HTTP 200). **Killing the warm analyzer** made `/health` fail, but Analyze still returned **200** (UI can fall back to another path — important surprise). **Blocking SQL** made Analyze **HTTP 500** (~24 s). **Stopping Ollama** left Analyze **200**. **CPU hog** made Analyze a bit slower but still **200**. After each fix, the stack came back. Soft vs hard matches what REL-002 / REL-004 / CHAOS-004 already taught.

---

## Scenarios we ran

| # | What we broke | Analyze mid-outage | Health / SQL / Ollama |
|---|---------------|--------------------|------------------------|
| S0 | Nothing (baseline) | **200** ~15 s | all OK |
| S1 | Kill analyzer `:8766` | **200** ~14 s (fallback) | health **FAIL**, SQL OK |
| S2 | Block SQL `:1433` | **500** ~24 s | SQL **closed**, health OK |
| S3 | Stop Ollama | **200** ~14 s | Ollama **down** |
| S4 | CPU hog (32 workers) | **200** ~15.6 s | all OK (slightly slower) |
| S5 | Final check | **200** ~14 s | all OK |

---

## What the screenshots show

Many PNGs under [screenshots/](./screenshots/) — not one chart only:

| File | Content |
|------|---------|
| `00-overview-matrix.png` | Every probe across every scenario |
| `s0-card.png` … `s5-card.png` | Per-scenario cards + alert-probe text |
| `analyze-across-scenarios.png` | Analyze HTTP/ms only |
| `terminal-summary.png` | Summary dump |
| `terminal-timeline.png` | Full timeline log |

Numbers: [results/game-day-probes.csv](./results/game-day-probes.csv)

---

## Takeaway

- **Page-worthy:** SQL down (hard fail), analyzer health down (even if Analyze falls back — ops should still care).
- **Ticket / soft:** Ollama down, CPU busy (slow but up).
- Game day ties REL + CHAOS + OBS-003 probes into one drill.

Re-run: [RUNBOOK.md](./RUNBOOK.md)

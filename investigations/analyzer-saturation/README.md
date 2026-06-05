# Analyzer saturation point

| | |
|---|---|
| **Status** | Complete |
| **ID** | LOAD-002 (saturation) |
| **Component** | One warm FastAPI analyzer `:8766` |
| **Tools** | Locust (staged GUI + continuous ramp) · Jaeger (optional) |
| **Builds on** | [LOAD-001 single-analyzer-capacity](../single-analyzer-capacity/) |
| **Environment** | Local dev (`cxr up`, `ANALYZER_URL` → `:8766`) |

---

## Question

At what concurrency does one warm analyzer **saturate** — p95 jumps sharply, failures appear, or RPS stops scaling?

LOAD-001 found **no knee at 15 users** (p95 ~1.5s, 0% failures). This investigation pushes **past 15** with staged tiers and a continuous user ramp.

## Hypothesis

Saturation appears between **20–35** concurrent analyze-only users — p95 climbs and/or failures > 0 before RPS flattens.

**Outcome:** Soft knee confirmed by **30–35** users (staged run). Continuous ramp to **~225 users** shows **throughput ceiling ~15–16 RPS** with **0% failures** and **tail latency runaway** (graceful degradation, not hard break).

## Method

1. `cxr up` — `curl http://127.0.0.1:8766/health` → `"warmed":"true"`.
2. **Staged ramp:** `run-saturation-locust-gui.sh` — **15 → 20 → 25 → 30 → 35** users (90s/tier).
3. **Continuous ramp:** `run-saturation-ramp-until-break-gui.sh` — start **15**, **+5** users every **60s** until Stop or cap **300**.
4. Record Locust **p95**, **failures**, **RPS**; compare to [LOAD-001](../single-analyzer-capacity/) baseline.

> **Locust ≠ Jaeger:** Locust = aggregate client wait under load (saturation knee). Jaeger = single-trace span breakdown. This report leads with Locust; prior LOAD-001 + staged Jaeger traces cover the “where time goes” lens.

---

## Run (scripts)

Dedicated wrappers — **do not edit** `single-analyzer-capacity/` defaults.

| Script | Purpose |
|--------|---------|
| [`run-saturation-locust-gui.sh`](./run-saturation-locust-gui.sh) | Staged GUI **15→35** on **:8090** |
| [`run-saturation-sweep.sh`](./run-saturation-sweep.sh) | Headless staged tiers → `results/saturation-sweep.csv` |
| [`run-saturation-ramp-until-break-gui.sh`](./run-saturation-ramp-until-break-gui.sh) | Continuous ramp until Stop / cap |
| [`run-saturation-until-break-sweep.sh`](./run-saturation-until-break-sweep.sh) | Headless step-up until first failures |
| [`locustfile-ramp-continuous.py`](./locustfile-ramp-continuous.py) | `ContinuousRampShape` for until-break GUI |

```bash
cxr up
./investigations/analyzer-saturation/run-saturation-ramp-until-break-gui.sh
# → http://127.0.0.1:8090 — leave terminal open, Start once, watch Charts
```

---

## Results

### Staged GUI — 15 → 35 users (2026-06-05)

| Observation | Value |
|-------------|-------|
| Ramp | 15 → 20 → 25 → 30 → 35 users |
| Failures | **0%** |
| RPS | ~**10** at peak tier |
| p95 | Mostly **~1.5–2s**; spikes **>3s** at **30–35** users |

Soft tail-latency knee at **30–35** users — no hard failure.

### Continuous ramp — primary evidence (2026-06-05)

~**40 minutes** continuous ramp (`run-saturation-ramp-until-break-gui.sh`). Users **15 → ~225** (+5 every 60s).

![Locust — continuous ramp to ~225 users, RPS plateau, p95 runaway](./screenshots/locust-continuous-ramp-225users-saturation.png)

| Phase | Users (approx) | RPS | Failures | p50 | p95 |
|-------|----------------:|----:|---------:|----:|----:|
| Early (~1:07 PM) | **54** | ~**12** | **0** | ~**1.1s** | ~**2.5s** |
| Saturation (~1:20 PM) | ~**100+** | **~15–16** (plateau) | **0** | climbing | climbing |
| Peak (~1:40 PM) | **~225** | **~15–16** (flat) | **0** | ~**12.5s** | ~**15–20s** |

**Interpretation:**

- **RPS ceiling ~15–16** — single warm analyzer + `:8251` path cannot push more throughput.
- **Users keep rising; RPS flat** — excess load becomes **queueing** (latency), not errors.
- **0% failures through 225 users** — graceful degradation, not crash.
- **Saturation signature:** RPS plateau + p95 runaway, not failure rate.

---

## Findings

1. **LOAD-001 headroom ends between 30–225 users** depending on metric: p95 degrades early (**30–35**); throughput caps later (**~15–16 RPS**).
2. **No HTTP error break** observed through **225** concurrent virtual users on local hardware.
3. **Knee is throughput-limited**, not error-limited — clients wait longer; analyzer still returns **200**.
4. **Continuous ramp** (`ContinuousRampShape`) is the right tool to find ceiling; fixed tier lists stop early (e.g. **35** was config cap, not CXR limit).

---

## Decision

- Treat **~15–16 RPS** and **p95 >5s sustained** as operational saturation signals for one warm `:8766` on this machine.
- For capacity planning: scale **out** (more analyzer replicas) or **queue** before **~50+** users if p95 SLA is ~2s.
- Jaeger at peak is **optional** for this report — Locust proves the knee; see LOAD-001 Jaeger for steady-state span shape.

---

## Follow-up

- [kill-analyzer-under-traffic/](../kill-analyzer-under-traffic/)
- [qdrant-outage/](../qdrant-outage/)
- [trace-propagation/](../trace-propagation/)

# Qdrant outage (DEP-001)

| | |
|---|---|
| **Status** | Complete |
| **ID** | DEP-001 |
| **Component** | Qdrant vector DB `:6333` + warm analyzer `:8766` |
| **Tools** | `curl`, Docker, Jaeger (optional) |
| **Environment** | Local dev (`cxr up`, `ANALYZER_URL` → `:8766`) |
| **Related** | [CHAOS-001 kill analyzer](../kill-analyzer-under-traffic/) · [LOAD-001](../single-analyzer-capacity/) |

---

## Question

How does analyze behave when Qdrant (`:6333`) is unavailable?

## Hypothesis

Analyze **degrades gracefully** — HTTP **200** with kernel **fallback retrieval** when Qdrant is down at boot; mid-outage behavior may differ if analyzer started with Qdrant connected.

## Method

1. `cxr up` — rehearsal `:8251`, analyzer `:8766`.
2. Start Qdrant Docker on **`:6333`** (`cxr-qdrant-outage-lab`).
3. **Baseline** — restart analyzer with Qdrant up; `POST /api/claim-studio/analyze`.
4. **Test A** — stop Qdrant; analyze **without** restarting analyzer.
5. **Recovery** — start Qdrant; analyze (analyzer not restarted).
6. **Test B** — stop Qdrant; restart analyzer; analyze (boot without Qdrant).
7. **Final** — both up; restart analyzer; analyze.

Automated: [`run-qdrant-outage-check.sh`](./run-qdrant-outage-check.sh) — **no Locust**.

```bash
cxr up
./investigations/qdrant-outage/run-qdrant-outage-check.sh
```

---

## Results (2026-06-05)

Timeline: [`results/qdrant-outage-timeline.log`](./results/qdrant-outage-timeline.log)

| Phase | Qdrant | HTTP | Latency | Notes |
|-------|--------|-----:|--------:|-------|
| **baseline_qdrant_up** | up | **200** | ~1.9s | Analyzer restarted with Qdrant |
| **test_a_mid_outage** | down | **200** | ~1.6s | Analyzer **not** restarted; Qdrant killed mid-run |
| **recovery_qdrant_up** | up | **200** | ~1.6s | Qdrant back; analyzer **not** restarted |
| **test_b_boot_without_qdrant** | down | **200** | ~1.6s | Analyzer restarted **without** Qdrant |
| **final_both_up** | up | **200** | ~1.8s | Both dependencies up |

**Summary:** **5/5 probes returned 200** — no user-visible hard failure.

Raw: [`results/qdrant-outage-summary.txt`](./results/qdrant-outage-summary.txt)

---

## Findings

1. **No HTTP 500** when Qdrant is down — analyze path stays up; differs from CHAOS-001 (analyzer kill → `fetch failed` / 500).
2. **Test A (mid-outage):** analyzer started with Qdrant connected still returned **200** after Qdrant stop — kernel likely uses in-process state / fallback on query failure (see `_get_semantic_evidence` fallback in `cxr_kernel_v4_final.py`).
3. **Test B (boot without Qdrant):** **200** at ~**1.6s** — startup logs `[WARN] Qdrant connection failed`; `qdrant_available = False`; fallback confidence path used.
4. **Latency flat** (~**1.5–1.9s**) across up/down — outage is **quality/degradation**, not wall-clock blow-up on this stack.
5. **Empty Qdrant caveat:** fresh Docker Qdrant had **no `claims__` policy collections** — even “Qdrant up” runs logged fallback-style warnings; test still valid for **connectivity** up vs down, not full retrieval quality.
6. **Recovery:** starting Qdrant alone was enough for next probe to return **200**; full retrieval may require populated collections + analyzer restart.

---

## Decision

- Treat Qdrant as **soft dependency** for local analyze — monitor `[WARN] Qdrant` in logs; do not expect automatic 500.
- For production: alert on Qdrant health; consider **readiness** that reflects `qdrant_available` if policy retrieval is required for compliance.
- **Jaeger optional** — compare `retrieval` / `context_builder` spans with vs without Qdrant if documenting for portfolio screenshots.

---

## Follow-up

- [trace-propagation/](../trace-propagation/)
- [planned/qdrant-retrieval-scaling.md](../planned/qdrant-retrieval-scaling.md) (performance, not failure)
- [planned/database-unavailable.md](../planned/database-unavailable.md) (SQL `:1433` — harder dependency)

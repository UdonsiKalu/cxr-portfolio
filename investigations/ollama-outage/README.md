# REL-002 — Ollama outage

| | |
|---|---|
| **Status** | Complete (2026-07-11) |
| **ID** | REL-002 |
| **Question** | What happens when Ollama (LLM) is down? |
| **Tools** | `curl`, `systemctl` (stop/start ollama), Jaeger optional |
| **Environment** | Local `cxr` stack — UI `:8251`, analyzer `:8766`, Ollama `:11434` |
| **Issue** | [#13](https://github.com/UdonsiKalu/cxr-portfolio/issues/13) |
| **Related** | [Qdrant outage (DEP-001)](../archive/old-investigations/qdrant-outage/) |

---

## What you can watch live

| App | Useful for this test? | What to look at |
|-----|----------------------|-----------------|
| **Jaeger** `:16686` | Yes | Service `cxr-analyzer-service` → `analyze_request`. Compliant claims show **`llm_inference.skipped`** (LLM never called). |
| **Claim Studio** `:8251` | Yes | Run Analyze with Ollama stopped — should still return a result. Auditor/Coach (audit) should fail with an Ollama connection error. |
| **Locust** `:8089` | No (optional) | This study is **single probes**, not a swarm. Locust would only show aggregate 200s — less useful here. |
| **Script log** | Yes | `results/ollama-outage-timeline.log` prints each phase as it runs. |

---

## Short story

Two different paths talk to Ollama:

1. **Analyze / policy recommendations** — only when the claim is **not Compliant** *and* policy docs exist. Our lab probes were **Compliant**, so the LLM was **skipped**. Stopping Ollama did **not** break Analyze (still HTTP **200**).
2. **Claim Studio audit / judge** — always wants Ollama. With Ollama down, audit returns HTTP **200** with `status: error` and a clear message: *Failed to connect to Ollama…*

So Ollama is a **soft** dependency for day-to-day Analyze (on Compliant traffic), and a **hard** dependency for the Auditor path.

---

## Method

Automated: [`run-ollama-outage-check.sh`](./run-ollama-outage-check.sh)

```bash
# Stack up (UI + analyzer + Jaeger). Ollama normally running.
./investigations/ollama-outage/run-ollama-outage-check.sh
```

Phases: baseline → stop Ollama → mid-outage analyze/audit → recover → boot analyzer without Ollama → final.

Extra check (unique audit digest, Ollama down): `results/audit-unique-ollama-down.json`.

---

## Results (2026-07-11)

| Phase | Kind | Ollama | HTTP | Note |
|-------|------|--------|-----:|------|
| baseline | analyze | up | **200** | archetype **Compliant** (~10s) |
| baseline | audit | up | 200 | `status=error` judge **timeout** (~15s) — lab judge flaky even when up |
| mid-outage | analyze | **down** | **200** | still Compliant (~10s) |
| mid-outage | audit | down | 200 | cached prior error (~0.2s) — same digest |
| unique audit | audit | **down** | 200 | **`Failed to connect to Ollama`** (~0.7s) — real outage signal |
| recovery / final | analyze | up | **200** | unchanged |
| boot without Ollama | analyze | down | **200** | analyzer warm OK; Analyze still works |

Raw: [results/ollama-outage-summary.txt](./results/ollama-outage-summary.txt) · [results/ollama-outage-probes.csv](./results/ollama-outage-probes.csv)

---

## Findings

1. **Analyze stays up** when Ollama is stopped — same pattern as Qdrant soft dependency for this lab claim shape.
2. **LLM often skipped** on Compliant claims (`llm_inference.skipped` in Jaeger) — killing Ollama cannot break a path that never calls it.
3. **Audit/judge hard-depends on Ollama** — connection error when down; when up, judge may still **timeout** on this machine (model/load) — separate reliability issue.
4. **Audit caches by digest** — re-auditing the same claim+result returns the cached error quickly; use a new claim id to retest.

---

## Decision

- Treat Ollama as **optional for Analyze** on Compliant traffic; **required for Auditor**.
- For production: health-check Ollama for audit features; don’t block Analyze readiness on Ollama if Compliant-only is acceptable.
- Portfolio: pair with [Qdrant outage](../archive/old-investigations/qdrant-outage/) as soft vs hard dependency contrast.

---

## Follow-up (optional)

- Force a **non-Compliant** claim with policy docs so Analyze actually hits `llm.model_request.send`, then repeat the outage.
- Fix / tune judge timeout when Ollama is up.
- Screenshots: Jaeger `llm_inference.skipped` + Claim Studio audit error toast.

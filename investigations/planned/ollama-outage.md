# REL-002 — Ollama outage

**Status:** Planned (Phase 2)

## Question

How does the recommendation / LLM path fail when Ollama or the configured LLM is down?

## Method (draft)

Stop LLM; verify recommendation path errors gracefully; note Compliant-only paths that skip LLM.

## Record results in

`cxr-ops-lab/evidence/` and promote to `ollama-outage/` folder when run.

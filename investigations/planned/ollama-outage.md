# REL-002 — Ollama outage

**Status:** **Promoted** — closed study: [../ollama-outage/](../ollama-outage/)

## Question

How does the recommendation / LLM path fail when Ollama or the configured LLM is down?

## Method (draft)

Stop LLM; verify recommendation path errors gracefully; note Compliant-only paths that skip LLM.

## Record results in

`investigations/ollama-outage/results/` (ran 2026-07-11).


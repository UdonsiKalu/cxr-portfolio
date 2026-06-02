# Runbook — Qdrant down

## Symptom

Logs: Qdrant connection refused :6333.

## Impact

Retrieval/policy anchor features degraded; warm analyze may still return 200.

## Action

Start Qdrant if needed for RAG demos; otherwise ignore for latency-only work.

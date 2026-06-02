# INC-001 — High API latency — Root cause

Per-request Python subprocess re-imported heavy deps; not Next.js alone.

Full record: [postmortem.md](./postmortem.md)

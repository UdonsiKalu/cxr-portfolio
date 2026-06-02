# INC-001 — High API latency — Timeline

| When | What |
|------|------|
| Investigation | Locust showed p95 ~10–12s on analyze API. |
| Resolution | Warm analyzer on :8766; `ANALYZER_URL`; re-run Locust. |

Full record: [postmortem.md](./postmortem.md)

# INC-003 — Python import bottleneck — Timeline

| When | What |
|------|------|
| Investigation | Wall clock >> kernel spans in Jaeger. |
| Resolution | FastAPI analyzer :8766; W3C propagation; ~21 spans warm path. |

Full record: [postmortem.md](./postmortem.md)

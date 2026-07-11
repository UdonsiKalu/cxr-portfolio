# Screenshots — REL-002 Ollama outage

Pictorial evidence from the lab capture (2026-07-11).

| File | What it shows |
|------|----------------|
| [results-table-ollama-outage.png](results-table-ollama-outage.png) | Full probe table — Analyze stays **200** with Ollama up or down |
| [auditor-ollama-down-error.png](auditor-ollama-down-error.png) | Auditor error: **Failed to connect to Ollama** (Ollama stopped) |
| [jaeger-analyze-waterfall-rel002.png](jaeger-analyze-waterfall-rel002.png) | Jaeger waterfall — `POST /api/claim-studio/analyze` **9.6s**, HTTP **200** (Compliant path; LLM skipped) |
| [claim-studio-ui.png](claim-studio-ui.png) | Claim Studio UI context |

Trace id: see `../results/jaeger-trace-id.txt` → open `http://127.0.0.1:16686/trace/<id>` when Jaeger is up.

HTML sources used for the styled panels (optional): `evidence-*.html` in this folder.

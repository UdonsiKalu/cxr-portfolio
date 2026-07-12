# Screenshots — REL-002 Ollama outage

Pictorial evidence (lab 2026-07-11; terminal pair refreshed 2026-07-12).

## Primary (reviewer path)

| File | What it shows |
|------|----------------|
| [terminal-ollama-on-baseline.png](terminal-ollama-on-baseline.png) | **ON:** Ollama up → Analyze **200** + Auditor **`status=done`** |
| [terminal-ollama-off-audit-error.png](terminal-ollama-off-audit-error.png) | **OFF:** Ollama stopped → Analyze **200** + Auditor **Failed to connect to Ollama** |

## Supporting

| File | What it shows |
|------|----------------|
| [results-table-ollama-outage.png](results-table-ollama-outage.png) | Full probe table from automated script |
| [auditor-ollama-down-error.png](auditor-ollama-down-error.png) | Claim Studio Auditor UI error panel |
| [jaeger-analyze-waterfall-rel002.png](jaeger-analyze-waterfall-rel002.png) | Jaeger — Analyze POST completes (Compliant / LLM skipped) |
| [claim-studio-ui.png](claim-studio-ui.png) | Claim Studio UI context |

Trace id: `../results/jaeger-trace-id.txt` → `http://127.0.0.1:16686/trace/<id>` when Jaeger is up.

HTML sources (optional): `evidence-*.html`.

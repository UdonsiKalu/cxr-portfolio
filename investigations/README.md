# Investigations

<!-- portfolio -->

Each **folder** is one question we ran (or will run) on the local CXR stack. Synthetic data, dev environment only.

> **Locust p95** (aggregate under load) ≠ **Jaeger** single-trace duration. Report both separately.

---

## Completed

| Investigation | Folder |
|---------------|--------|
| Claim analysis latency | [latency-investigation/](./latency-investigation/) |
| Locust load baseline | [load-testing/](./load-testing/) |
| Missing spans / trace profile | [missing-spans/](./missing-spans/) |
| Postmortems | [postmortems/](./postmortems/) |
| Cold vs warm analyzer | [cold-vs-warm-analyzer/](./cold-vs-warm-analyzer/) |
| Single analyzer capacity | [single-analyzer-capacity/](./single-analyzer-capacity/) |
| Analyzer saturation | [analyzer-saturation/](./analyzer-saturation/) |

---

## Run next (Phase 1)

| # | Investigation | Folder |
|---|---------------|--------|
| 1 | Kill analyzer under traffic | [kill-analyzer-under-traffic/](./kill-analyzer-under-traffic/) |
| 2 | Qdrant outage | [qdrant-outage/](./qdrant-outage/) |
| 3 | Trace propagation | [trace-propagation/](./trace-propagation/) |
| 4 | Platform bootstrap | [planned/platform-bootstrap.md](./planned/platform-bootstrap.md) |

Backlog: [planned/](./planned/)

---

## Tools

### Jaeger {#jaeger}

http://127.0.0.1:16686 — filter **`cxr-ui-rehearsal`** → **`POST /api/claim-studio/analyze`** (not GET pages).

| Operation | Meaning |
|-----------|---------|
| `analyzer_service.analyze_request` | Warm analyze on :8766 |
| `context_builder` | Main kernel time when warm |
| `analyzer_service.startup` | ~7–8s once per boot |

Evidence: [latency-investigation/screenshots/](./latency-investigation/screenshots/)

### Trace profiles {#trace-profiles}

Default **`CXR_TRACE_PROFILE=detailed`**. **`minimal`** was rejected (~7 spans vs ~21; harder to debug). See [missing-spans/](./missing-spans/).

### Locust {#locust}

http://127.0.0.1:8089 → target `http://127.0.0.1:8251`. Start with `cxr up`. Results: [load-testing/](./load-testing/).

### OpenTelemetry {#opentelemetry}

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318
export CXR_TRACE_PROFILE=detailed
```

Apps send spans to **:4318** (OTLP); Jaeger UI on **:16686** displays them. Next.js passes **traceparent** to the analyzer for linked traces.

---

## Report template

Question → Hypothesis → Method → Tools → Metrics → Results → Findings → Decision → Follow-up

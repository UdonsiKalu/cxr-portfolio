# Postmortems index

Incident-style narratives: **what happened**, **timeline**, **root cause**, **lessons**, **follow-ups**.

Canonical files: [`investigations/postmortems/`](../investigations/postmortems/).

---

## Records

| Postmortem | Related investigation | Summary |
|------------|----------------------|---------|
| [Python import bottleneck](../investigations/postmortems/python-import-bottleneck.md) | [latency-investigation](../investigations/latency-investigation/) | Subprocess-per-request re-imported heavy ML stack every call |
| [High API latency under load](../investigations/postmortems/high-latency-under-load.md) | [latency-investigation](../investigations/latency-investigation/) | Load-test view of the latency crisis |
| [Jaeger trace profile UX](../investigations/postmortems/jaeger-trace-profile.md) | [missing-spans](../investigations/missing-spans/) | Trace visualization trade-offs |

---

## Postmortem vs investigation vs failure index

| Type | When to use |
|------|-------------|
| **Investigation** | Structured study with hypothesis and method |
| **Postmortem** | User- or system-visible regression with timeline |
| **[Failures index](../failures/README.md)** | Short row linking to a failed experiment or reverted path |

Not every failed load test needs a full postmortem. GATE-002 candidate 1 is indexed under [failures/](../failures/README.md); OBS-001 is a full [run doc](../investigations/kubernetes-analyzer-saturation/evidence/load-observe/RUN-2026-06-17.md) plus CHANGELOG entries.

---

## Related

- [CHANGELOG](../CHANGELOG.md) — Investigations section  
- [history.md](../history.md) — curated arcs

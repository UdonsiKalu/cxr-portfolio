# Results — OBS-003 alerting probes

| File | What |
|------|------|
| [one-shot-pass.txt](./one-shot-pass.txt) | Captured one-shot run: A2 health + A3 SQL + A1 Analyze all PASS |
| [cxr_obs003_probe.prom](./cxr_obs003_probe.prom) | Prometheus textfile from that run |
| [alerts-sample.log](./alerts-sample.log) | Sample lines from `alerts.log` |

Reproduce:

```bash
./investigations/alerting-strategy/run-alert-probes.sh
```

Plain English: [../RESULTS.md](../RESULTS.md) · [../RUNBOOK.md](../RUNBOOK.md)

# OBS-003 — Prometheus alert rules (draft)

Use with metrics written by `../run-alert-probes.sh` → `cxr_obs003_probe.prom`.

## Metrics

| Metric | Meaning |
|--------|---------|
| `cxr_obs003_probe_success{check="analyzer_health"}` | A2 — 1=PASS 0=FAIL |
| `cxr_obs003_probe_success{check="sql"}` | A3 |
| `cxr_obs003_probe_success{check="analyze"}` | A1 |

## Wire into local Prometheus (cxr-ops-lab)

1. Keep the probe loop running (writes the `.prom` file).
2. Scrape the textfile — easiest options:
   - **node_exporter** `--collector.textfile.directory=.../alerting-strategy/prometheus`
   - or copy/symlink `cxr_obs003_alert_rules.yml` into `cxr-ops-lab/observe/prometheus/` and add a scrape job that hits a tiny static file exporter
3. Load alert rules: add to `rule_files` in `observe/prometheus.yml`:
   - `/etc/prometheus/cxr_obs003_alert_rules.yml`
4. Reload Prometheus. Check **Status → Rules** and **Alerts**.

Until scraped, the bash **ALERT** lines in the terminal are your working pager.

See [cxr_obs003_alert_rules.yml](./cxr_obs003_alert_rules.yml) · [RUNBOOK.md](../RUNBOOK.md)

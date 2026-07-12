# OBS-003 probe runbook (simple)

## What the script checks

| Code | Check | PASS means |
|------|--------|------------|
| **A2** | `GET :8766/health` | Analyzer up |
| **A3** | TCP to `:1433` | SQL port open |
| **A1** | `POST :8251/.../analyze` | Analyze returns HTTP 2xx |

## Run once

```bash
cd ~/staging/cxr-portfolio
./investigations/alerting-strategy/run-alert-probes.sh
```

Expect three PASS lines (Analyze may take ~10–30s).

Fast loop without Analyze:

```bash
CXR_ALERT_SKIP_ANALYZE=1 CXR_ALERT_INTERVAL_SEC=5 \
  ./investigations/alerting-strategy/run-alert-probes.sh --loop
```

## Loop + ALERT

```bash
./investigations/alerting-strategy/run-alert-probes.sh --loop
```

After **3** bad cycles → terminal **ALERT**. Recovery → **CLEAR**.

## Prometheus (Step 6)

1. Script writes `prometheus/cxr_obs003_probe.prom` each cycle.
2. Alert rules draft: `prometheus/cxr_obs003_alert_rules.yml`
3. Wire scrape + `rule_files` in cxr-ops-lab observe stack — see `prometheus/README.md`.

Until Prometheus is wired, trust the **PASS/FAIL/ALERT** lines and `alerts.log`.

## How to force FAIL (lab)

| To fail | Do |
|---------|-----|
| A2 | Stop analyzer `:8766` |
| A3 | Block SQL `:1433` (REL-004 iptables) or stop SQL |
| A1 | Stop analyzer or block SQL (Analyze 5xx) |

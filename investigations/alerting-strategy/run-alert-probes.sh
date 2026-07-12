#!/usr/bin/env bash
# OBS-003 Phase 1 probes
#   default: one-shot A2 health + A3 SQL + A1 Analyze
#   --loop: every 30s; ALERT after N consecutive bad cycles; CLEAR on recover
#   writes Prometheus textfile: prometheus/cxr_obs003_probe.prom
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${SCRIPT_DIR}/alerts.log"
METRICS_FILE="${SCRIPT_DIR}/prometheus/cxr_obs003_probe.prom"
HEALTH_URL="${CXR_ANALYZER_HEALTH_URL:-http://127.0.0.1:8766/health}"
SQL_HOST="${CXR_SQL_HOST:-127.0.0.1}"
SQL_PORT="${CXR_SQL_PORT:-1433}"
UI_HOST="${CXR_UI_HOST:-http://127.0.0.1:8251}"
ANALYZE_URL="${CXR_ANALYZE_URL:-${UI_HOST}/api/claim-studio/analyze}"
INTERVAL_SEC="${CXR_ALERT_INTERVAL_SEC:-30}"
FAIL_THRESHOLD="${CXR_ALERT_FAIL_THRESHOLD:-3}"
SKIP_ANALYZE="${CXR_ALERT_SKIP_ANALYZE:-0}"

LOOP=0
if [[ "${1:-}" == "--loop" ]] || [[ "${CXR_ALERT_LOOP:-0}" == "1" ]]; then
  LOOP=1
fi

mkdir -p "$(dirname "$METRICS_FILE")"

log_line() {
  echo "$(date -Iseconds) $*" >>"$LOG"
}

write_prom_metrics() {
  local a2="$1" a3="$2" a1="$3"
  cat >"${METRICS_FILE}.$$" <<EOF
# HELP cxr_obs003_probe_success 1=pass 0=fail for OBS-003 blackbox probes
# TYPE cxr_obs003_probe_success gauge
cxr_obs003_probe_success{check="analyzer_health"} ${a2}
cxr_obs003_probe_success{check="sql"} ${a3}
cxr_obs003_probe_success{check="analyze"} ${a1}
# HELP cxr_obs003_probe_cycle_unixtime Unix time of last probe cycle
# TYPE cxr_obs003_probe_cycle_unixtime gauge
cxr_obs003_probe_cycle_unixtime $(date +%s)
EOF
  mv "${METRICS_FILE}.$$" "$METRICS_FILE"
}

# Exit 0 only if A2+A3+A1 all pass (A1 skip counts as pass).
run_cycle() {
  local a2=0 a3=0 a1=0 rc=0 code ok claim_id

  # A2 — analyzer /health
  code="000"
  if code="$(curl -sS -o /tmp/cxr-alert-health.json -w "%{http_code}" --connect-timeout 3 --max-time 5 "$HEALTH_URL" 2>/dev/null)"; then
    :
  else
    code="000"
  fi
  if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then
    echo "PASS A2 health (HTTP ${code})"
    log_line "PASS A2 analyzer_health http=${code}"
    a2=1
  else
    echo "FAIL A2 health (HTTP ${code})" >&2
    log_line "FAIL A2 analyzer_health http=${code}"
    a2=0
    rc=1
  fi

  # A3 — SQL TCP :1433
  ok=0
  if command -v nc >/dev/null 2>&1; then
    nc -z -w 3 "$SQL_HOST" "$SQL_PORT" 2>/dev/null && ok=1
  elif timeout 3 bash -c "echo >/dev/tcp/${SQL_HOST}/${SQL_PORT}" 2>/dev/null; then
    ok=1
  fi
  if [[ "$ok" -eq 1 ]]; then
    echo "PASS A3 sql (${SQL_HOST}:${SQL_PORT} open)"
    log_line "PASS A3 sql ${SQL_HOST}:${SQL_PORT}"
    a3=1
  else
    echo "FAIL A3 sql (${SQL_HOST}:${SQL_PORT} closed/unreachable)" >&2
    log_line "FAIL A3 sql ${SQL_HOST}:${SQL_PORT}"
    a3=0
    rc=1
  fi

  # A1 — Analyze POST (slow; skip with CXR_ALERT_SKIP_ANALYZE=1)
  if [[ "$SKIP_ANALYZE" == "1" ]]; then
    echo "SKIP A1 analyze (CXR_ALERT_SKIP_ANALYZE=1)"
    a1=1
  else
    claim_id="obs003-$(date +%s)"
    code="000"
    if code="$(curl -sS -m 120 -X POST "$ANALYZE_URL" \
      -H 'Content-Type: application/json' \
      -d "{\"input\":{\"content\":\"{\\\"claim_id\\\":\\\"${claim_id}\\\",\\\"description\\\":\\\"office visit (obs-003 probe)\\\"}\"}}" \
      -o /tmp/cxr-alert-analyze.json -w "%{http_code}" 2>/dev/null)"; then
      :
    else
      code="000"
    fi
    if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then
      echo "PASS A1 analyze (HTTP ${code})"
      log_line "PASS A1 analyze http=${code}"
      a1=1
    else
      echo "FAIL A1 analyze (HTTP ${code})" >&2
      log_line "FAIL A1 analyze http=${code}"
      a1=0
      rc=1
    fi
  fi

  write_prom_metrics "$a2" "$a3" "$a1"
  return "$rc"
}

if [[ "$LOOP" -eq 0 ]]; then
  echo "OBS-003 one-shot: A2 health + A3 SQL + A1 Analyze"
  echo "metrics: $METRICS_FILE"
  run_cycle
  exit $?
fi

echo "OBS-003 loop: A2+A3+A1 every ${INTERVAL_SEC}s; ALERT after ${FAIL_THRESHOLD} bad cycles (Ctrl+C)"
echo "log: $LOG"
echo "metrics: $METRICS_FILE"
[[ "$SKIP_ANALYZE" == "1" ]] && echo "(Analyze skipped)"

consecutive_fails=0
alert_open=0

while true; do
  if run_cycle; then
    if [[ "$alert_open" -eq 1 ]]; then
      echo "CLEAR: all probes recovered (alert closed)"
      log_line "CLEAR probes recovered"
      alert_open=0
    fi
    consecutive_fails=0
  else
    consecutive_fails=$((consecutive_fails + 1))
    echo "consecutive bad cycles: ${consecutive_fails}/${FAIL_THRESHOLD}"
    if [[ "$consecutive_fails" -ge "$FAIL_THRESHOLD" && "$alert_open" -eq 0 ]]; then
      echo "ALERT: probe cycle failed ${FAIL_THRESHOLD} times in a row — page-worthy (A1/A2/A3)" >&2
      log_line "ALERT probes consecutive_fails=${consecutive_fails}"
      alert_open=1
    fi
  fi
  sleep "$INTERVAL_SEC"
done

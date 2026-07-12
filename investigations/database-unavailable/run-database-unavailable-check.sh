#!/usr/bin/env bash
# REL-004 - Database unavailable: make SQL :1433 unreachable, observe analyze (+ optional diag), recover.
# Method: iptables REJECT on tcp/1433 (leaves mssql-server running; faster/safer than systemctl stop).
# Prereq: rehearsal :8251, analyzer :8766 warmed. Locust NOT required.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${HERE}/results"
TIMELINE="${OUT_DIR}/database-unavailable-timeline.log"
SUMMARY="${OUT_DIR}/database-unavailable-summary.txt"
CSV="${OUT_DIR}/database-unavailable-probes.csv"

HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
ANALYZER_URL="${CXR_ANALYZER_URL:-http://127.0.0.1:8766}"
SQL_HOST="${CXR_SQL_PROBE_HOST:-127.0.0.1}"
SQL_PORT="${CXR_SQL_PROBE_PORT:-1433}"

mkdir -p "${OUT_DIR}"
: > "${TIMELINE}"
echo "phase,kind,http,ms,sql,note" > "${CSV}"

log() {
  echo "$(date -Iseconds)  $*" | tee -a "${TIMELINE}"
}

sql_up() {
  timeout 2 bash -c "echo > /dev/tcp/${SQL_HOST}/${SQL_PORT}" >/dev/null 2>&1
}

block_sql() {
  # Prefer non-interactive sudo. Do NOT use interactive sudo (hangs agents).
  if ! sudo -n true 2>/dev/null; then
    echo "ERROR: need passwordless sudo for iptables (or run rules yourself)." >&2
    echo "  sudo iptables -I INPUT -p tcp --dport ${SQL_PORT} -j REJECT --reject-with tcp-reset" >&2
    echo "  sudo iptables -I OUTPUT -p tcp --dport ${SQL_PORT} -j REJECT --reject-with tcp-reset" >&2
    exit 2
  fi
  sudo -n iptables -I INPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset
  sudo -n iptables -I OUTPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset
  sleep 1
  if sql_up; then
    log "WARN sql_still_reachable after block"
  else
    log "sql_blocked port=${SQL_PORT}"
  fi
}

unblock_sql() {
  sudo -n iptables -D INPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset 2>/dev/null || true
  sudo -n iptables -D OUTPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset 2>/dev/null || true
  # delete again in case duplicates
  sudo -n iptables -D INPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset 2>/dev/null || true
  sudo -n iptables -D OUTPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset 2>/dev/null || true
  sleep 1
  if sql_up; then
    log "sql_unblocked_ok"
  else
    log "WARN sql_still_unreachable after unblock — check iptables / mssql-server"
  fi
}

trap 'unblock_sql' EXIT

probe_analyze() {
  local phase="$1"
  local claim_id="rel-004-${phase}-$(date +%s)"
  local out="${OUT_DIR}/analyze-${phase}.json"
  local t0 t1 ms code note sql_state
  sql_state=$(sql_up && echo up || echo down)
  t0=$(date +%s%3N)
  code=$(curl -sS -m 120 -X POST "${HOST}/api/claim-studio/analyze" \
    -H 'Content-Type: application/json' \
    -d "{\"input\":{\"content\":\"{\\\"claim_id\\\":\\\"${claim_id}\\\",\\\"description\\\":\\\"office visit (sql outage)\\\"}\"}}" \
    -o "${out}" -w '%{http_code}' || echo 000)
  t1=$(date +%s%3N)
  ms=$((t1 - t0))
  note=$(python3 - <<PY
import json
try:
  d=json.load(open("${out}"))
except Exception:
  print("no_json"); raise SystemExit
if d.get("ok") is True:
  r=d.get("result") or {}
  print(r.get("archetype") or r.get("decision") or "ok")
else:
  err=str(d.get("error") or d.get("detail") or "error")[:80].replace(",", ";")
  print(err or "error")
PY
)
  log "${phase} [analyze]: http=${code} ms=${ms} sql=${sql_state} note=${note}"
  echo "${phase},analyze,${code},${ms},${sql_state},${note}" >> "${CSV}"
}

probe_diag() {
  local phase="$1"
  local out="${OUT_DIR}/diag-${phase}.json"
  local t0 t1 ms code sql_state note
  sql_state=$(sql_up && echo up || echo down)
  t0=$(date +%s%3N)
  code=$(curl -sS -m 30 "${HOST}/api/terminal/diag" -o "${out}" -w '%{http_code}' || echo 000)
  t1=$(date +%s%3N)
  ms=$((t1 - t0))
  note=$(python3 - <<PY
import json
try:
  d=json.load(open("${out}"))
except Exception:
  print("no_json"); raise SystemExit
if d.get("ok") is True:
  print("diag_ok")
else:
  print(str(d.get("error") or d.get("message") or "error")[:80].replace(",", ";"))
PY
)
  log "${phase} [diag]: http=${code} ms=${ms} sql=${sql_state} note=${note}"
  echo "${phase},diag,${code},${ms},${sql_state},${note}" >> "${CSV}"
}

echo "== REL-004 Database unavailable =="
echo "  Watch: Claim Studio ${HOST}/claim-studio  Jaeger optional"
echo "  Method: iptables REJECT tcp/${SQL_PORT} (mssql stays running)"
echo ""

curl -sf -m 5 "${ANALYZER_URL}/health" >/dev/null || {
  echo "ERROR: analyzer ${ANALYZER_URL}/health failed — start warm analyzer first" >&2
  exit 1
}
sql_up || {
  echo "ERROR: SQL ${SQL_HOST}:${SQL_PORT} not reachable at start" >&2
  exit 1
}

log "baseline_begin"
probe_analyze baseline_sql_up
probe_diag baseline_sql_up

log "outage_begin"
block_sql
probe_analyze mid_outage_sql_down
probe_diag mid_outage_sql_down

log "recovery_begin"
unblock_sql
# disarm trap duplicate unblock
trap - EXIT
probe_analyze recovery_sql_up
probe_diag recovery_sql_up

{
  echo "REL-004 Database unavailable — summary"
  echo "generated=$(date -Iseconds)"
  echo ""
  cat "${CSV}"
  echo ""
  echo "timeline:"
  cat "${TIMELINE}"
} | tee "${SUMMARY}"

log "done"
echo ""
echo "Results: ${OUT_DIR}"
echo "Summary: ${SUMMARY}"

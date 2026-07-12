#!/usr/bin/env bash
# Game day — combined failure drill (sequential scenarios + recover between each).
# Reuses REL-004 SQL block, REL-002 Ollama stop, analyzer kill, optional CPU hog.
# Also records OBS-003 blackbox probe one-shots per phase for screenshots.
# Prereq: :8251, warm :8766, SQL :1433, passwordless sudo (iptables + ollama).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PORTFOLIO="$(cd "${HERE}/../.." && pwd)"
STAGING="${CXR_STAGING:-/home/udonsi-kalu/staging}"
CAT_ROOT="${CXR_CLAIM_ANALYSIS_TOOLS:-${STAGING}/cxrlabs-dev/claim_analysis_tools}"
OUT="${HERE}/results"
SHOTS="${HERE}/screenshots"
HTML="${HERE}/html"
CSV="${OUT}/game-day-probes.csv"
TIMELINE="${OUT}/game-day-timeline.log"
SUMMARY="${OUT}/game-day-summary.txt"
ALERT_PROBES="${PORTFOLIO}/investigations/alerting-strategy/run-alert-probes.sh"

HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
ANALYZER_URL="${CXR_ANALYZER_URL:-http://127.0.0.1:8766}"
SQL_HOST="${CXR_SQL_PROBE_HOST:-127.0.0.1}"
SQL_PORT="${CXR_SQL_PROBE_PORT:-1433}"
OLLAMA_URL="${CXR_OLLAMA_URL:-http://127.0.0.1:11434}"
SKIP_CPU="${CXR_GAME_DAY_SKIP_CPU:-0}"
SKIP_OLLAMA="${CXR_GAME_DAY_SKIP_OLLAMA:-0}"
ANALYZE_TIMEOUT="${CXR_ANALYZE_TIMEOUT_SEC:-120}"

mkdir -p "${OUT}" "${SHOTS}" "${HTML}"
: > "${TIMELINE}"
echo "scenario,phase,check,http_or_status,ms,note" > "${CSV}"

log() { echo "$(date -Iseconds)  $*" | tee -a "${TIMELINE}"; }

sql_up() { timeout 2 bash -c "echo > /dev/tcp/${SQL_HOST}/${SQL_PORT}" >/dev/null 2>&1; }
ollama_up() { curl -sf -m 3 "${OLLAMA_URL}/api/tags" >/dev/null 2>&1; }
analyzer_up() { curl -sf -m 3 "${ANALYZER_URL}/health" >/dev/null 2>&1; }

row() {
  # scenario,phase,check,http_or_status,ms,note
  echo "$1,$2,$3,$4,$5,$6" >> "${CSV}"
  log "[$1/$2] $3 status=$4 ms=$5 note=$6"
}

block_sql() {
  sudo -n iptables -I INPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset
  sudo -n iptables -I OUTPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset
  sleep 1
}
unblock_sql() {
  sudo -n iptables -D INPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset 2>/dev/null || true
  sudo -n iptables -D OUTPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset 2>/dev/null || true
  sudo -n iptables -D INPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset 2>/dev/null || true
  sudo -n iptables -D OUTPUT -p tcp --dport "${SQL_PORT}" -j REJECT --reject-with tcp-reset 2>/dev/null || true
  sleep 1
}

kill_analyzer() {
  fuser -k 8766/tcp 2>/dev/null || true
  sleep 1
}

start_analyzer() {
  # shellcheck disable=SC1091
  source "${CAT_ROOT}/scripts/use_faiss_venv.sh" 2>/dev/null || true
  export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://127.0.0.1:4318}"
  export CXR_TRACE_PROFILE="${CXR_TRACE_PROFILE:-detailed}"
  nohup bash "${CAT_ROOT}/scripts/start_analyzer_service.sh" >>/tmp/cxr-analyzer-service.log 2>&1 &
  local i
  for i in $(seq 1 90); do
    if curl -sf -m 3 "${ANALYZER_URL}/health" | grep -qi 'warmed'; then
      log "analyzer_warmed elapsed_s=${i}"
      return 0
    fi
    sleep 1
  done
  echo "ERROR: analyzer did not warm" >&2
  return 1
}

stop_ollama() { sudo -n systemctl stop ollama; sleep 2; }
start_ollama() { sudo -n systemctl start ollama; sleep 2; }

probe_health() {
  local scen="$1" phase="$2"
  local code ms t0 t1
  t0=$(date +%s%3N)
  code=$(curl -sS -o "${OUT}/health-${scen}-${phase}.json" -w '%{http_code}' --connect-timeout 2 --max-time 5 "${ANALYZER_URL}/health" 2>/dev/null || true)
  [[ -z "${code}" || "${code}" == "000000" ]] && code="000"
  # curl may print 000 on failure; normalize
  code="${code: -3}"
  [[ "${code}" =~ ^[0-9]{3}$ ]] || code="000"
  t1=$(date +%s%3N)
  ms=$((t1 - t0))
  row "${scen}" "${phase}" "A2_health" "${code}" "${ms}" "health"
}

probe_sql() {
  local scen="$1" phase="$2"
  if sql_up; then
    row "${scen}" "${phase}" "A3_sql" "open" "0" "tcp_${SQL_PORT}"
  else
    row "${scen}" "${phase}" "A3_sql" "closed" "0" "tcp_${SQL_PORT}"
  fi
}

probe_analyze() {
  local scen="$1" phase="$2"
  local claim="gameday-${scen}-${phase}-$(date +%s%N)"
  local out="${OUT}/analyze-${scen}-${phase}.json"
  local t0 t1 ms code note
  t0=$(date +%s%3N)
  code=$(curl -sS -m "${ANALYZE_TIMEOUT}" -X POST "${HOST}/api/claim-studio/analyze" \
    -H 'Content-Type: application/json' \
    -d "{\"input\":{\"content\":\"{\\\"claim_id\\\":\\\"${claim}\\\",\\\"description\\\":\\\"office visit diabetes follow up evaluation\\\"}\"}}" \
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
  print(str(d.get("error") or d.get("detail") or "error")[:60].replace(",",";"))
PY
)
  row "${scen}" "${phase}" "A1_analyze" "${code}" "${ms}" "${note}"
}

probe_ollama() {
  local scen="$1" phase="$2"
  if ollama_up; then
    row "${scen}" "${phase}" "ollama" "up" "0" "api_tags"
  else
    row "${scen}" "${phase}" "ollama" "down" "0" "api_tags"
  fi
}

run_alert_oneshot() {
  local scen="$1" phase="$2"
  local out="${OUT}/alert-probes-${scen}-${phase}.txt"
  if [[ -x "${ALERT_PROBES}" ]]; then
    set +e
    # Skip Analyze inside alert script — we already probe A1 separately (faster + clearer screenshots)
    CXR_ALERT_SKIP_ANALYZE=1 "${ALERT_PROBES}" >"${out}" 2>&1
    local rc=$?
    set -e
    row "${scen}" "${phase}" "alert_probes_rc" "${rc}" "0" "skip_analyze"
  fi
}

snapshot_all() {
  local scen="$1" phase="$2"
  probe_health "${scen}" "${phase}"
  probe_sql "${scen}" "${phase}"
  probe_ollama "${scen}" "${phase}"
  probe_analyze "${scen}" "${phase}"
  run_alert_oneshot "${scen}" "${phase}"
}

cleanup() {
  log "cleanup_begin"
  unblock_sql || true
  if ! ollama_up; then start_ollama || true; fi
  if ! analyzer_up; then start_analyzer || true; fi
  # stop any leftover cpu hog from chaos study
  if [[ -x "${PORTFOLIO}/investigations/cpu-starvation/run-cpu-starvation-check.sh" ]]; then
    "${PORTFOLIO}/investigations/cpu-starvation/run-cpu-starvation-check.sh" --phase stop-hog >/dev/null 2>&1 || true
  fi
  log "cleanup_end"
}
trap cleanup EXIT

echo "== Game day — combined failure drill =="
echo "  UI ${HOST}  analyzer ${ANALYZER_URL}"
echo ""

sudo -n true || { echo "ERROR: need passwordless sudo"; exit 2; }
analyzer_up || { echo "ERROR: analyzer not up — start warm :8766 first"; exit 1; }
sql_up || { echo "ERROR: SQL not reachable"; exit 1; }

# ---------- S0 baseline ----------
log "S0_baseline_begin"
snapshot_all S0 baseline
log "S0_baseline_end"

# ---------- S1 analyzer down ----------
log "S1_analyzer_down_begin"
kill_analyzer
snapshot_all S1 mid_outage
log "S1_recover_begin"
start_analyzer
snapshot_all S1 recovered
log "S1_analyzer_down_end"

# ---------- S2 SQL down ----------
log "S2_sql_down_begin"
block_sql
snapshot_all S2 mid_outage
log "S2_recover_begin"
unblock_sql
snapshot_all S2 recovered
log "S2_sql_down_end"

# ---------- S3 Ollama down ----------
if [[ "${SKIP_OLLAMA}" != "1" ]]; then
  log "S3_ollama_down_begin"
  stop_ollama
  snapshot_all S3 mid_outage
  log "S3_recover_begin"
  start_ollama
  snapshot_all S3 recovered
  log "S3_ollama_down_end"
else
  log "S3_skipped"
fi

# ---------- S4 CPU starvation (short) ----------
if [[ "${SKIP_CPU}" != "1" ]] && [[ -x "${PORTFOLIO}/investigations/cpu-starvation/run-cpu-starvation-check.sh" ]]; then
  log "S4_cpu_begin"
  CXR_CPU_PROBES=1 CXR_CPU_WORKERS="${CXR_CPU_WORKERS:-32}" \
    "${PORTFOLIO}/investigations/cpu-starvation/run-cpu-starvation-check.sh" --phase starved \
    >"${OUT}/s4-cpu-starved.txt" 2>&1 || true
  # steal last analyze row from cpu csv if present — also our own snapshot while hog may still run
  snapshot_all S4 mid_outage
  "${PORTFOLIO}/investigations/cpu-starvation/run-cpu-starvation-check.sh" --phase stop-hog >/dev/null 2>&1 || true
  sleep 2
  snapshot_all S4 recovered
  log "S4_cpu_end"
else
  log "S4_skipped"
fi

# Final healthy check
snapshot_all S5 final

python3 - <<PY | tee "${SUMMARY}"
import csv
from pathlib import Path
csv_path = Path("${CSV}")
rows = list(csv.DictReader(csv_path.open()))
print("Game day — summary")
print("generated=$(date -Iseconds)")
print()
for scen in ("S0","S1","S2","S3","S4","S5"):
    subset = [r for r in rows if r["scenario"] == scen]
    if not subset:
        continue
    print(f"=== {scen} ===")
    for r in subset:
        if r["check"] in ("A1_analyze","A2_health","A3_sql","ollama","alert_probes_rc"):
            print(f"  {r['phase']:12} {r['check']:16} {r['http_or_status']:>6}  {r['ms']:>6}ms  {r['note']}")
    print()
print("csv:", csv_path)
print("timeline:", "${TIMELINE}")
PY

log "done"
echo ""
echo "Results: ${OUT}"
echo "Next: python3 ${HERE}/render-game-day-screenshots.py"

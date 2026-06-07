#!/usr/bin/env bash
# CHAOS-001 — kill :8766 mid-Locust, restart, measure recovery to warmed.
# Prereq: cxr up (rehearsal :8251 warmed analyzer).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
LOAD001="${HERE}/../single-analyzer-capacity"
OPS_ROOT="${CXR_OPS_LAB:-/home/udonsi-kalu/staging/cxr-ops-lab}"
STAGING_ROOT="${CXR_STAGING:-/home/udonsi-kalu/staging}"
CAT_ROOT="${CXR_CLAIM_ANALYSIS_TOOLS:-${STAGING_ROOT}/cxrlabs-dev/claim_analysis_tools}"
VENV="${OPS_ROOT}/load/locust/.venv"
HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
ANALYZER_PORT="${CXR_ANALYZER_PORT:-8766}"
ANALYZER_URL="http://127.0.0.1:${ANALYZER_PORT}"
OUT_DIR="${HERE}/results"

USERS="${CXR_CHAOS_USERS:-5}"
DURATION="${CXR_CHAOS_DURATION:-120s}"
BASELINE_SEC="${CXR_CHAOS_BASELINE_SEC:-15}"
OUTAGE_HOLD_SEC="${CXR_CHAOS_OUTAGE_HOLD_SEC:-10}"
LOG_ANALYZER="${CXR_ANALYZER_LOG:-/tmp/cxr-analyzer-service.log}"

mkdir -p "${OUT_DIR}"

if [[ ! -x "${VENV}/bin/locust" ]]; then
  python3 -m venv "${VENV}"
  "${VENV}/bin/pip" install -q --upgrade pip
  "${VENV}/bin/pip" install -q -r "${OPS_ROOT}/load/locust/requirements.txt"
fi

health_json() { curl -sf "${ANALYZER_URL}/health" 2>/dev/null || echo "{}"; }
is_warmed() { health_json | grep -q '"warmed":"true"'; }
is_up() { curl -sf "${ANALYZER_URL}/health" >/dev/null 2>&1; }

log_event() {
  local msg="$1"
  local ts
  ts="$(date -Iseconds)"
  echo "${ts}  ${msg}" | tee -a "${OUT_DIR}/kill-chaos-timeline.log"
}

if ! curl -sf "${HOST}/claim-studio" >/dev/null; then
  echo "Rehearsal not up at ${HOST} — run: cxr up" >&2
  exit 1
fi
if ! is_warmed; then
  echo "Analyzer not warmed at ${ANALYZER_URL}/health — wait or cxr up" >&2
  exit 1
fi

TAG="chaos-$(date +%Y%m%dT%H%M%S)"
TIMELINE="${OUT_DIR}/kill-chaos-timeline.log"
SUMMARY="${OUT_DIR}/kill-chaos-summary.txt"
: > "${TIMELINE}"

echo "== CHAOS-001 kill analyzer under traffic =="
echo "  Users:     ${USERS}  Duration: ${DURATION}"
echo "  Baseline:  ${BASELINE_SEC}s before kill"
echo "  Outage:    hold ${OUTAGE_HOLD_SEC}s after kill before restart"
echo "  Timeline:  ${TIMELINE}"
echo ""

log_event "preflight_ok users=${USERS} warmed=true"

"${VENV}/bin/locust" \
  -f "${HERE}/locustfile-chaos-steady.py" \
  --host "${HOST}" \
  --headless \
  -u "${USERS}" \
  -r 1 \
  -t "${DURATION}" \
  --csv "${OUT_DIR}/${TAG}" \
  --only-summary >"${OUT_DIR}/${TAG}.log" 2>&1 &
LOCUST_PID=$!
log_event "locust_started pid=${LOCUST_PID}"

sleep "${BASELINE_SEC}"
log_event "analyzer_kill"
fuser -k "${ANALYZER_PORT}/tcp" 2>/dev/null || true
sleep 2
if is_up; then
  log_event "WARN analyzer_still_up after kill"
else
  log_event "analyzer_down confirmed"
fi

sleep "${OUTAGE_HOLD_SEC}"

log_event "analyzer_restart_begin"
(
  export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://127.0.0.1:4318}"
  export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-cxr-analyzer-service}"
  export CXR_TRACE_PROFILE="${CXR_TRACE_PROFILE:-detailed}"
  cd "${CAT_ROOT}"
  nohup ./scripts/start_analyzer_service.sh >>"${LOG_ANALYZER}" 2>&1 &
)
RECOVERY_START=$()

for i in $(seq 1 120); do
  if is_up; then
    log_event "health_responding elapsed_s=${i}"
    break
  fi
  sleep 1
done

WARMED_SEC=""
for i in $(seq 1 120); do
  if is_warmed; then
    WARMED_SEC=$i
    log_event "warmed_true recovery_to_warm_s=${i}"
    break
  fi
  sleep 1
done

if [[ -z "${WARMED_SEC}" ]]; then
  log_event "ERROR warmed_timeout_120s"
fi

wait "${LOCUST_PID}" 2>/dev/null || true
# Headless may outlive -t if requests hang; cap wait at duration + 60s
if kill -0 "${LOCUST_PID}" 2>/dev/null; then
  log_event "locust_still_running sending SIGTERM"
  kill "${LOCUST_PID}" 2>/dev/null || true
  wait "${LOCUST_PID}" 2>/dev/null || true
fi
log_event "locust_finished"

STATS="${OUT_DIR}/${TAG}_stats.csv"
python3 - "${STATS}" "${SUMMARY}" "${WARMED_SEC}" <<'PY'
import csv, sys
stats_path, summary_path, warmed = sys.argv[1:4]
rows = list(csv.DictReader(open(stats_path, newline=""))) if stats_path else []
row = next((r for r in rows if r.get("Name") == "POST /api/claim-studio/analyze"), rows[-1] if rows else {})
def num(k, d=0):
    try: return float(row.get(k, d) or d)
    except ValueError: return d
fails = int(num("Failure Count"))
reqs = int(num("Request Count"))
with open(summary_path, "w") as out:
    out.write(f"requests={reqs}\n")
    out.write(f"failures={fails}\n")
    out.write(f"failure_pct={100*fails/reqs if reqs else 0:.2f}\n")
    out.write(f"median_ms={num('Median Response Time'):.0f}\n")
    out.write(f"p95_ms={num('95%'):.0f}\n")
    out.write(f"recovery_to_warm_s={warmed or 'timeout'}\n")
print(f"  → requests={reqs} failures={fails} p95={num('95%'):.0f}ms recovery_warm_s={warmed or 'timeout'}")
PY

echo ""
echo "Wrote ${SUMMARY}"
echo "Wrote ${TIMELINE}"
cat "${SUMMARY}"

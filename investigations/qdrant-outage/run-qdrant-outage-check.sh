#!/usr/bin/env bash
# DEP-001 — Qdrant outage: stop :6333, observe analyze behavior, recover.
# Prereq: cxr up (rehearsal :8251, analyzer :8766). No Locust.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OPS_ROOT="${CXR_OPS_LAB:-/home/udonsi-kalu/staging/cxr-ops-lab}"
STAGING_ROOT="${CXR_STAGING:-/home/udonsi-kalu/staging}"
CAT_ROOT="${CXR_CLAIM_ANALYSIS_TOOLS:-${STAGING_ROOT}/cxrlabs-dev/claim_analysis_tools}"
OUT_DIR="${HERE}/results"
TIMELINE="${OUT_DIR}/qdrant-outage-timeline.log"
SUMMARY="${OUT_DIR}/qdrant-outage-summary.txt"

HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
ANALYZER_PORT="${CXR_ANALYZER_PORT:-8766}"
ANALYZER_URL="http://127.0.0.1:${ANALYZER_PORT}"
QDRANT_PORT="${CXR_QDRANT_PORT:-6333}"
QDRANT_URL="http://127.0.0.1:${QDRANT_PORT}"
QDRANT_CONTAINER="${CXR_QDRANT_CONTAINER:-cxr-qdrant-outage-lab}"
LOG_ANALYZER="${CXR_ANALYZER_LOG:-/tmp/cxr-analyzer-service.log}"

mkdir -p "${OUT_DIR}"
: > "${TIMELINE}"

log() {
  echo "$(date -Iseconds)  $*" | tee -a "${TIMELINE}"
}

qdrant_up() {
  curl -sf "${QDRANT_URL}/" >/dev/null 2>&1
}

start_qdrant() {
  if qdrant_up; then
    log "qdrant_already_up url=${QDRANT_URL}"
    return 0
  fi
  if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "${QDRANT_CONTAINER}"; then
    log "qdrant_docker_start name=${QDRANT_CONTAINER}"
    docker start "${QDRANT_CONTAINER}" >/dev/null
  else
    log "qdrant_docker_run name=${QDRANT_CONTAINER} port=${QDRANT_PORT}"
    docker run -d --name "${QDRANT_CONTAINER}" -p "${QDRANT_PORT}:6333" qdrant/qdrant:latest >/dev/null
  fi
  for i in $(seq 1 30); do
    qdrant_up && { log "qdrant_ready elapsed_s=${i}"; return 0; }
    sleep 1
  done
  echo "ERROR: Qdrant did not start on ${QDRANT_URL}" >&2
  exit 1
}

stop_qdrant() {
  if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "${QDRANT_CONTAINER}"; then
    log "qdrant_docker_stop name=${QDRANT_CONTAINER}"
    docker stop "${QDRANT_CONTAINER}" >/dev/null
  else
    log "qdrant_stop_skip (container not running)"
  fi
  sleep 2
}

kill_analyzer() {
  fuser -k "${ANALYZER_PORT}/tcp" 2>/dev/null || true
  sleep 2
}

start_analyzer() {
  log "analyzer_restart_begin"
  (
    export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://127.0.0.1:4318}"
    export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-cxr-analyzer-service}"
    export CXR_TRACE_PROFILE="${CXR_TRACE_PROFILE:-detailed}"
    cd "${CAT_ROOT}"
    nohup ./scripts/start_analyzer_service.sh >>"${LOG_ANALYZER}" 2>&1 &
  )
  for i in $(seq 1 120); do
    if curl -sf "${ANALYZER_URL}/health" | grep -q '"warmed":"true"'; then
      log "analyzer_warmed elapsed_s=${i}"
      return 0
    fi
    sleep 1
  done
  echo "ERROR: analyzer not warmed after 120s" >&2
  exit 1
}

post_analyze() {
  local label="$1"
  local tmp
  tmp="$(mktemp)"
  local start end elapsed code
  start=$(date +%s%3N)
  code=$(curl -sf -o "${tmp}" -w "%{http_code}" \
    -X POST "${HOST}/api/claim-studio/analyze" \
    -H "Content-Type: application/json" \
    -d '{"input":{"content":"{\"claim_id\":\"dep-001-qdrant-outage\",\"description\":\"office visit (qdrant outage test)\"}"}}' \
    --max-time 120 2>/dev/null) || code="000"
  end=$(date +%s%3N)
  elapsed=$(( end - start ))
  local err=""
  if [[ -f "${tmp}" ]]; then
    err=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print((d.get('error') or d.get('detail') or '')[:120])" "${tmp}" 2>/dev/null || head -c 120 "${tmp}")
  fi
  log "analyze label=${label} http=${code} ms=${elapsed} qdrant_up=$(qdrant_up && echo true || echo false) err=${err:-none}"
  rm -f "${tmp}"
  echo "${label},${code},${elapsed},$(qdrant_up && echo up || echo down)" >> "${OUT_DIR}/qdrant-outage-probes.csv"
}

if ! curl -sf "${HOST}/claim-studio" >/dev/null; then
  echo "ERROR: rehearsal not up at ${HOST} — run: cxr up" >&2
  exit 1
fi

echo "phase,http_code,elapsed_ms,qdrant_state" > "${OUT_DIR}/qdrant-outage-probes.csv"

echo "== DEP-001 Qdrant outage =="
echo "  Qdrant:    ${QDRANT_URL} (container ${QDRANT_CONTAINER})"
echo "  Timeline:  ${TIMELINE}"
echo ""

log "preflight host=${HOST} analyzer=${ANALYZER_URL}"

# --- Baseline: Qdrant up, fresh analyzer boot ---
start_qdrant
kill_analyzer
start_analyzer
post_analyze "baseline_qdrant_up"

# --- Test A: kill Qdrant mid-flight (analyzer still warm, started with Qdrant) ---
stop_qdrant
post_analyze "test_a_mid_outage_no_analyzer_restart"

# --- Recovery: Qdrant back (analyzer not restarted) ---
start_qdrant
sleep 3
post_analyze "recovery_qdrant_up_analyzer_not_restarted"

# --- Test B: analyzer boot without Qdrant ---
stop_qdrant
kill_analyzer
start_analyzer
post_analyze "test_b_boot_without_qdrant"

# --- Final recovery ---
start_qdrant
kill_analyzer
start_analyzer
post_analyze "final_both_up"

python3 - "${OUT_DIR}/qdrant-outage-probes.csv" "${SUMMARY}" <<'PY'
import csv, sys
probes, summary = sys.argv[1:3]
rows = list(csv.DictReader(open(probes, newline="")))
with open(summary, "w") as out:
    for r in rows:
        out.write(f"{r['phase']}: http={r['http_code']} ms={r['elapsed_ms']} qdrant={r['qdrant_state']}\n")
    fails = [r for r in rows if r["http_code"] != "200"]
    out.write(f"\ntotal_probes={len(rows)} non_200={len(fails)}\n")
print(open(summary).read())
PY

echo ""
echo "Wrote ${SUMMARY}"

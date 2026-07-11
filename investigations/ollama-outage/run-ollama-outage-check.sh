#!/usr/bin/env bash
# REL-002 - Ollama outage: stop :11434, observe analyze + audit/judge, recover.
# Prereq: rehearsal :8251, analyzer :8766 warmed, Jaeger optional.
# Locust is NOT required - open Jaeger + Claim Studio if you want to watch live.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
STAGING_ROOT="${CXR_STAGING:-/home/udonsi-kalu/staging}"
CAT_ROOT="${CXR_CLAIM_ANALYSIS_TOOLS:-${STAGING_ROOT}/cxrlabs-dev/claim_analysis_tools}"
OUT_DIR="${HERE}/results"
TIMELINE="${OUT_DIR}/ollama-outage-timeline.log"
SUMMARY="${OUT_DIR}/ollama-outage-summary.txt"

HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
ANALYZER_PORT="${CXR_ANALYZER_PORT:-8766}"
ANALYZER_URL="http://127.0.0.1:${ANALYZER_PORT}"
OLLAMA_URL="${CXR_OLLAMA_URL:-http://127.0.0.1:11434}"
LOG_ANALYZER="${CXR_ANALYZER_LOG:-/tmp/cxr-analyzer-service.log}"

mkdir -p "${OUT_DIR}"
: > "${TIMELINE}"

log() {
  echo "$(date -Iseconds)  $*" | tee -a "${TIMELINE}"
}

ollama_up() {
  curl -sf -m 3 "${OLLAMA_URL}/api/tags" >/dev/null 2>&1
}

start_ollama() {
  if ollama_up; then
    log "ollama_already_up url=${OLLAMA_URL}"
    return 0
  fi
  log "ollama_systemctl_start"
  systemctl start ollama 2>/dev/null || sudo systemctl start ollama
  for i in $(seq 1 30); do
    ollama_up && { log "ollama_ready elapsed_s=${i}"; return 0; }
    sleep 1
  done
  echo "ERROR: Ollama did not start on ${OLLAMA_URL}" >&2
  exit 1
}

stop_ollama() {
  log "ollama_systemctl_stop"
  systemctl stop ollama 2>/dev/null || sudo systemctl stop ollama || true
  sleep 2
  if ollama_up; then
    log "ollama_still_up_after_stop - trying pkill"
    pkill -f 'ollama serve' 2>/dev/null || true
    sleep 2
  fi
  ollama_up && log "WARN ollama_still_reachable" || log "ollama_down_confirmed"
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
    if curl -sf "${ANALYZER_URL}/health" 2>/dev/null | grep -q 'warmed'; then
      # warmed may be bool or string
      if curl -sf "${ANALYZER_URL}/health" | grep -qE '"warmed"[[:space:]]*:[[:space:]]*(true|"true")'; then
        log "analyzer_warmed elapsed_s=${i}"
        return 0
      fi
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
  code=$(curl -s -o "${tmp}" -w "%{http_code}" \
    -X POST "${HOST}/api/claim-studio/analyze" \
    -H "Content-Type: application/json" \
    -d '{"input":{"content":"{\"claim_id\":\"rel-002-ollama-outage\",\"description\":\"office visit (ollama outage test)\"}"}}' \
    --max-time 180 2>/dev/null) || code="000"
  end=$(date +%s%3N)
  elapsed=$(( end - start ))
  local arch="?"
  if [[ -f "${tmp}" ]]; then
    arch=$(python3 -c "import json; d=json.load(open('${tmp}')); r=d.get('result') or {}; print(r.get('archetype') or r.get('primary_archetype') or '?')" 2>/dev/null || echo "?")
    cp "${tmp}" "${OUT_DIR}/analyze-${label}.json"
  fi
  local ou
  ou=$(ollama_up && echo up || echo down)
  log "analyze label=${label} http=${code} ms=${elapsed} ollama=${ou} archetype=${arch}"
  echo "${label},analyze,${code},${elapsed},${ou},${arch}" >> "${OUT_DIR}/ollama-outage-probes.csv"
  rm -f "${tmp}"
}

post_audit() {
  local label="$1"
  local analyze_json="$2"
  local tmp
  tmp="$(mktemp)"
  local start end elapsed code
  start=$(date +%s%3N)
  code=$(AUDIT_HOST="${HOST}" python3 - "$analyze_json" "${tmp}" <<'PY'
import json, sys, os, urllib.error, urllib.request
src, outp = sys.argv[1:3]
host = os.environ.get("AUDIT_HOST", "http://127.0.0.1:8251").rstrip("/")
d = json.load(open(src))
body = json.dumps({"claim": d.get("claim") or {"claim_id": "rel-002"}, "result": d.get("result") or {}}).encode()
req = urllib.request.Request(
    f"{host}/api/claim-studio/audit/start",
    data=body,
    headers={"Content-Type": "application/json"},
)
try:
    with urllib.request.urlopen(req, timeout=90) as resp:
        open(outp, "wb").write(resp.read())
        print(resp.status)
except urllib.error.HTTPError as e:
    open(outp, "wb").write(e.read() or b"")
    print(e.code)
except Exception as e:
    open(outp, "wb").write(str(e).encode())
    print("000")
PY
) || code="000"
  end=$(date +%s%3N)
  elapsed=$(( end - start ))
  local status="?"
  if [[ -f "${tmp}" ]]; then
    status=$(python3 -c "import json; d=json.load(open('${tmp}')); print(d.get('status') or d.get('error') or (d.get('record') or {}).get('status') or '?')" 2>/dev/null || echo "?")
    cp "${tmp}" "${OUT_DIR}/audit-${label}.json"
  fi
  local ou
  ou=$(ollama_up && echo up || echo down)
  log "audit label=${label} http=${code} ms=${elapsed} ollama=${ou} status=${status}"
  echo "${label},audit,${code},${elapsed},${ou},${status}" >> "${OUT_DIR}/ollama-outage-probes.csv"
  rm -f "${tmp}"
}

if ! curl -sf "${HOST}/claim-studio" >/dev/null; then
  echo "ERROR: rehearsal not up at ${HOST}" >&2
  exit 1
fi

echo "phase,kind,http_code,elapsed_ms,ollama_state,note" > "${OUT_DIR}/ollama-outage-probes.csv"

echo "== REL-002 Ollama outage =="
echo "  Watch live:"
echo "    Jaeger   http://127.0.0.1:16686  (service cxr-analyzer-service / cxr-ui-rehearsal)"
echo "    Studio   http://127.0.0.1:8251/claim-studio"
echo "    Locust   not used for this test (optional)"
echo "  Timeline:  ${TIMELINE}"
echo ""

log "preflight host=${HOST} analyzer=${ANALYZER_URL}"

# --- Baseline: Ollama up ---
start_ollama
if ! curl -sf "${ANALYZER_URL}/health" | grep -qE '"warmed"[[:space:]]*:[[:space:]]*(true|"true")'; then
  kill_analyzer
  start_analyzer
fi
post_analyze "baseline_ollama_up"
# reuse last analyze JSON for audit
post_audit "baseline_ollama_up" "${OUT_DIR}/analyze-baseline_ollama_up.json"

# --- Mid-outage: Ollama down, analyzer not restarted ---
stop_ollama
post_analyze "test_a_mid_outage_analyze"
post_audit "test_a_mid_outage_audit" "${OUT_DIR}/analyze-baseline_ollama_up.json"

# --- Recovery ---
start_ollama
sleep 3
post_analyze "recovery_analyze"
post_audit "recovery_audit" "${OUT_DIR}/analyze-recovery_analyze.json"

# --- Boot without Ollama ---
stop_ollama
kill_analyzer
start_analyzer
post_analyze "test_b_boot_without_ollama"

# --- Final ---
start_ollama
kill_analyzer
start_analyzer
post_analyze "final_both_up"

python3 - "${OUT_DIR}/ollama-outage-probes.csv" "${SUMMARY}" <<'PY'
import csv, sys
probes, summary = sys.argv[1:3]
rows = list(csv.DictReader(open(probes, newline="")))
with open(summary, "w") as out:
    for r in rows:
        out.write(
            f"{r['phase']} [{r['kind']}]: http={r['http_code']} ms={r['elapsed_ms']} "
            f"ollama={r['ollama_state']} note={r['note']}\n"
        )
    fails = [r for r in rows if r["http_code"] not in ("200",)]
    out.write(f"\ntotal_probes={len(rows)} non_200={len(fails)}\n")
print(open(summary).read())
PY

echo ""
echo "Wrote ${SUMMARY}"
echo "Jaeger: look for recent POST / analyze_request - Compliant runs show llm_inference.skipped"

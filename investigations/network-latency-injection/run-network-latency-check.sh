#!/usr/bin/env bash
# CHAOS-002 — Network latency on warm analyzer HTTP hop via delay proxy :8767→:8766.
# Prereq: warm analyzer :8766. Locust NOT required.
# Probes POST http://127.0.0.1:8767/analyze (through proxy). Claim Studio :8251 may be
# subprocess-only on some trees; this study isolates the HTTP hop the warm stack uses.
#
# Usage:
#   ./run-network-latency-check.sh                 # all tiers
#   ./run-network-latency-check.sh --phase baseline
#   ./run-network-latency-check.sh --phase latency-100|latency-500|latency-2000
#   ./run-network-latency-check.sh --phase recovery
#   ./run-network-latency-check.sh --phase stop-proxy
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${HERE}/results"
TIMELINE="${OUT_DIR}/network-latency-timeline.log"
SUMMARY="${OUT_DIR}/network-latency-summary.txt"
CSV="${OUT_DIR}/network-latency-probes.csv"
PROXY_PID_FILE="${OUT_DIR}/.delay-proxy.pid"
PROXY_LOG="${OUT_DIR}/delay-proxy.log"

ANALYZER_DIRECT="${CXR_ANALYZER_URL:-http://127.0.0.1:8766}"
PROXY_URL="${CXR_PROXY_URL:-http://127.0.0.1:8767}"
PROBES_PER_PHASE="${CXR_NET_PROBES:-2}"
ANALYZE_TIMEOUT="${CXR_ANALYZE_TIMEOUT_SEC:-300}"
PHASE="all"

# Tier delays (ms) for full run
TIERS=(0 100 500 2000 0)
TIER_NAMES=(baseline latency-100 latency-500 latency-2000 recovery)

usage() {
  cat <<'EOF'
CHAOS-002 — Network latency runner

Usage:
  ./run-network-latency-check.sh
  ./run-network-latency-check.sh --phase baseline|latency-100|latency-500|latency-2000|recovery|stop-proxy

Env: CXR_NET_PROBES, CXR_LOAD_URL, CXR_PROXY_URL, CXR_ANALYZER_URL
Probes the warm HTTP analyzer through the delay proxy (not Locust).
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase) PHASE="${2:-}"; shift 2 ;;
    --phase=*) PHASE="${1#*=}"; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

case "${PHASE}" in
  all|baseline|latency-100|latency-500|latency-2000|recovery|stop-proxy) ;;
  *) echo "ERROR: bad --phase ${PHASE}" >&2; exit 2 ;;
esac

mkdir -p "${OUT_DIR}"

if [[ "${PHASE}" == "all" ]]; then
  : > "${TIMELINE}"
  echo "phase,probe,http,ms,delay_ms,note" > "${CSV}"
elif [[ ! -f "${CSV}" ]]; then
  echo "phase,probe,http,ms,delay_ms,note" > "${CSV}"
  : > "${TIMELINE}"
fi

log() {
  echo "$(date -Iseconds)  $*" | tee -a "${TIMELINE}"
}

set_proxy_delay() {
  local ms="$1"
  curl -sf -m 5 -X POST "${PROXY_URL}/__cxr_proxy/delay" \
    -H 'Content-Type: application/json' \
    -d "{\"ms\": ${ms}}" >/dev/null
  log "proxy_delay_ms=${ms}"
}

stop_proxy() {
  if [[ -f "${PROXY_PID_FILE}" ]]; then
    local pid
    pid="$(cat "${PROXY_PID_FILE}" 2>/dev/null || true)"
    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
      kill -TERM "${pid}" 2>/dev/null || true
      sleep 0.5
      kill -KILL "${pid}" 2>/dev/null || true
    fi
    rm -f "${PROXY_PID_FILE}"
    log "proxy_stopped"
  fi
}

start_proxy() {
  if curl -sf -m 2 "${PROXY_URL}/__cxr_proxy/status" >/dev/null 2>&1; then
    log "proxy already up"
    return 0
  fi
  python3 "${HERE}/delay_proxy.py" \
    --listen "127.0.0.1:${PROXY_URL##*:}" \
    --upstream "127.0.0.1:${ANALYZER_DIRECT##*:}" \
    --delay-ms 0 >>"${PROXY_LOG}" 2>&1 &
  echo $! > "${PROXY_PID_FILE}"
  local i
  for i in $(seq 1 30); do
    if curl -sf -m 1 "${PROXY_URL}/__cxr_proxy/status" >/dev/null 2>&1; then
      log "proxy_started pid=$(cat "${PROXY_PID_FILE}")"
      return 0
    fi
    sleep 0.2
  done
  echo "ERROR: delay proxy failed to start; see ${PROXY_LOG}" >&2
  exit 1
}

probe_analyze() {
  local phase="$1"
  local i="$2"
  local delay_ms="$3"
  local out="${OUT_DIR}/analyze-${phase}-p${i}.json"
  local claim="chaos002-${phase}-p${i}-$(date +%s%N)"
  local t0 t1 ms code note
  t0=$(date +%s%3N)
  # Warm FastAPI analyzer — body shape { "claim": { ... } }
  code=$(curl -sS -m "${ANALYZE_TIMEOUT}" -X POST "${PROXY_URL}/analyze" \
    -H 'Content-Type: application/json' \
    -d "{\"claim\":{\"claim_id\":\"${claim}\",\"description\":\"office visit diabetes follow up evaluation\"}}" \
    -o "${out}" -w '%{http_code}' || echo 000)
  t1=$(date +%s%3N)
  ms=$((t1 - t0))
  note=$(python3 - <<PY
import json
try:
  d=json.load(open("${out}"))
except Exception:
  print("no_json"); raise SystemExit
if d.get("status") == "success" or d.get("ok") is True:
  r = d.get("result") or {}
  print(r.get("archetype") or r.get("decision") or d.get("status") or "ok")
else:
  err=str(d.get("error") or d.get("detail") or d.get("proxy_error") or "error")[:80]
  if not isinstance(err, str):
    err = str(err)[:80]
  print(err.replace(",", ";") or "error")
PY
)
  log "${phase} [analyze p${i}]: http=${code} ms=${ms} delay_ms=${delay_ms} note=${note}"
  echo "${phase},${i},${code},${ms},${delay_ms},${note}" >> "${CSV}"
}

run_tier() {
  local phase="$1"
  local delay_ms="$2"
  local i
  set_proxy_delay "${delay_ms}"
  log "phase_begin ${phase} delay_ms=${delay_ms}"
  for i in $(seq 1 "${PROBES_PER_PHASE}"); do
    probe_analyze "${phase}" "${i}" "${delay_ms}"
  done
  log "phase_end ${phase}"
}

write_summary() {
  {
    echo "CHAOS-002 Network latency — summary"
    echo "generated=$(date -Iseconds)"
    echo "probes_per_phase=${PROBES_PER_PHASE}"
    echo "proxy=${PROXY_URL}"
    echo "analyzer_direct=${ANALYZER_DIRECT}"
    echo "phase_mode=${PHASE}"
    echo ""
    python3 - <<PY
import csv, statistics
rows = list(csv.DictReader(open("${CSV}")))
order = ["baseline","latency-100","latency-500","latency-2000","recovery"]
seen = []
for phase in order + [r["phase"] for r in rows]:
    if phase in seen:
        continue
    if not any(r["phase"] == phase for r in rows):
        continue
    seen.append(phase)
    ms = [int(r["ms"]) for r in rows if r["phase"] == phase]
    codes = [r["http"] for r in rows if r["phase"] == phase]
    dms = [r["delay_ms"] for r in rows if r["phase"] == phase]
    print(
        f"{phase}: n={len(ms)} http={','.join(codes)} delay_ms={dms[0] if dms else '?'} "
        f"ms_min={min(ms)} ms_median={statistics.median(ms):.0f} ms_max={max(ms)}"
    )
PY
    echo ""
    echo "csv:"
    cat "${CSV}"
    echo ""
    echo "timeline:"
    cat "${TIMELINE}"
  } | tee "${SUMMARY}"
}

preflight() {
  curl -sf -m 5 "${ANALYZER_DIRECT}/health" | tee "${OUT_DIR}/analyzer-health.json"
  echo
  python3 - <<PY
import json
d=json.load(open("${OUT_DIR}/analyzer-health.json"))
assert d.get("status") == "ok", d
assert str(d.get("warmed")).lower() in ("true", "1", "yes"), d
print("analyzer warm OK")
PY
  start_proxy
  curl -sf -m 5 "${PROXY_URL}/health" | tee "${OUT_DIR}/proxy-health.json"
  echo
  log "preflight OK — probes hit ${PROXY_URL}/analyze"
}

phase_to_delay() {
  case "$1" in
    baseline|recovery) echo 0 ;;
    latency-100) echo 100 ;;
    latency-500) echo 500 ;;
    latency-2000) echo 2000 ;;
    *) echo 0 ;;
  esac
}

trap 'if [[ "${PHASE}" == "all" ]]; then set_proxy_delay 0 2>/dev/null || true; fi' EXIT

case "${PHASE}" in
  stop-proxy)
    stop_proxy
    exit 0
    ;;
  all)
    preflight
    local_i=0
    for local_i in "${!TIERS[@]}"; do
      run_tier "${TIER_NAMES[$local_i]}" "${TIERS[$local_i]}"
    done
    set_proxy_delay 0
    write_summary
    ;;
  *)
    preflight
    run_tier "${PHASE}" "$(phase_to_delay "${PHASE}")"
    write_summary
    ;;
esac

log "done phase=${PHASE}"
echo "Summary: ${SUMMARY}"
echo "CSV: ${CSV}"

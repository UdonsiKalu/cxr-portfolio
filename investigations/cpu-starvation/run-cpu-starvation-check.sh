#!/usr/bin/env bash
# CHAOS-004 — CPU starvation: burn host CPUs while measuring Analyze latency.
# Prereq: rehearsal :8251, warm analyzer :8766. Locust NOT required.
# Method: Python busy-loop workers (no stress-ng install needed).
#
# Usage:
#   ./run-cpu-starvation-check.sh                  # all phases (default)
#   ./run-cpu-starvation-check.sh --phase baseline  # probes only, no hog
#   ./run-cpu-starvation-check.sh --phase starved   # start hog + probes
#   ./run-cpu-starvation-check.sh --phase recovery  # stop hog + probes
#   ./run-cpu-starvation-check.sh --phase stop-hog  # stop hog only
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${HERE}/results"
TIMELINE="${OUT_DIR}/cpu-starvation-timeline.log"
SUMMARY="${OUT_DIR}/cpu-starvation-summary.txt"
CSV="${OUT_DIR}/cpu-starvation-probes.csv"
HOG_PID_FILE="${OUT_DIR}/.cpu-hog.pids"

HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
ANALYZER_URL="${CXR_ANALYZER_URL:-http://127.0.0.1:8766}"
PROBES_PER_PHASE="${CXR_CPU_PROBES:-3}"
NPROC="$(nproc)"
DEFAULT_WORKERS=$(( NPROC > 2 ? NPROC - 2 : NPROC ))
WORKERS="${CXR_CPU_WORKERS:-$DEFAULT_WORKERS}"
STRESS_SETTLE_SEC="${CXR_CPU_SETTLE_SEC:-3}"
ANALYZE_TIMEOUT="${CXR_ANALYZE_TIMEOUT_SEC:-180}"
ACTIVE_WORKERS=0
PHASE="all"
RESET_CSV=0

usage() {
  cat <<'EOF'
CHAOS-004 — CPU starvation runner

Usage:
  ./run-cpu-starvation-check.sh                  # all phases (default)
  ./run-cpu-starvation-check.sh --phase baseline  # probes only, no hog
  ./run-cpu-starvation-check.sh --phase starved   # start hog + probes (hog stays up)
  ./run-cpu-starvation-check.sh --phase recovery  # stop hog + probes
  ./run-cpu-starvation-check.sh --phase stop-hog  # stop hog only

Env: CXR_CPU_WORKERS, CXR_CPU_PROBES, CXR_LOAD_URL, CXR_ANALYZER_URL
Locust is NOT required — this script POSTs Analyze itself.
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase)
      PHASE="${2:-}"
      shift 2
      ;;
    --phase=*)
      PHASE="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown arg: $1 (try --help)" >&2
      exit 2
      ;;
  esac
done

case "${PHASE}" in
  all|baseline|starved|recovery|stop-hog) ;;
  *)
    echo "ERROR: --phase must be all|baseline|starved|recovery|stop-hog (got: ${PHASE})" >&2
    exit 2
    ;;
esac

mkdir -p "${OUT_DIR}"

# Full run resets CSV/timeline; single-phase appends (for screenshot workflows).
if [[ "${PHASE}" == "all" ]]; then
  RESET_CSV=1
fi
if [[ "${RESET_CSV}" -eq 1 ]] || [[ ! -f "${CSV}" ]]; then
  : > "${TIMELINE}"
  echo "phase,probe,http,ms,load1,load5,workers,note" > "${CSV}"
  : > "${OUT_DIR}/loadavg-snapshots.txt"
fi

log() {
  echo "$(date -Iseconds)  $*" | tee -a "${TIMELINE}"
}

loadavg_1() { awk '{print $1}' /proc/loadavg; }
loadavg_5() { awk '{print $2}' /proc/loadavg; }

# Hog leader PID is line 1 of pidfile (session leader from setsid).
# Kill the whole process group, wait briefly, then SIGKILL stragglers.
stop_hog() {
  ACTIVE_WORKERS=0
  if [[ ! -f "${HOG_PID_FILE}" ]]; then
    return 0
  fi
  local pids=()
  local leader=""
  local pid
  mapfile -t pids < "${HOG_PID_FILE}" || true
  rm -f "${HOG_PID_FILE}"
  leader="${pids[0]:-}"
  if [[ -z "${leader}" ]]; then
    return 0
  fi

  # Prefer process-group kill (setsid → PGID == leader PID).
  if kill -0 "${leader}" 2>/dev/null; then
    kill -TERM -- "-${leader}" 2>/dev/null || kill -TERM "${leader}" 2>/dev/null || true
  fi
  # Also TERM any listed PIDs (covers stale lists / non-group cases).
  for pid in "${pids[@]}"; do
    [[ -z "${pid}" ]] && continue
    kill -TERM "${pid}" 2>/dev/null || true
  done

  local i
  for i in $(seq 1 20); do
    local alive=0
    for pid in "${pids[@]}"; do
      [[ -z "${pid}" ]] && continue
      if kill -0 "${pid}" 2>/dev/null; then
        alive=1
        break
      fi
    done
    [[ "${alive}" -eq 0 ]] && break
    sleep 0.1
  done

  kill -KILL -- "-${leader}" 2>/dev/null || true
  for pid in "${pids[@]}"; do
    [[ -z "${pid}" ]] && continue
    if kill -0 "${pid}" 2>/dev/null; then
      kill -KILL "${pid}" 2>/dev/null || true
    fi
  done
  # Reap background job if this shell started it
  wait 2>/dev/null || true
}

start_hog() {
  local workers="$1"
  stop_hog
  # New session so stop_hog can kill -- -PGID
  setsid python3 "${HERE}/cpu_hog.py" "${workers}" "${HOG_PID_FILE}" </dev/null >/dev/null 2>&1 &
  local i
  for i in $(seq 1 50); do
    [[ -f "${HOG_PID_FILE}" ]] && break
    sleep 0.1
  done
  if [[ ! -f "${HOG_PID_FILE}" ]]; then
    echo "ERROR: CPU hog failed to start" >&2
    exit 1
  fi
  ACTIVE_WORKERS="${workers}"
  sleep "${STRESS_SETTLE_SEC}"
}

probe_analyze() {
  local phase="$1"
  local i="$2"
  local out="${OUT_DIR}/analyze-${phase}-p${i}.json"
  local claim="chaos004-${phase}-p${i}-$(date +%s%N)"
  local t0 t1 ms code note load1 load5
  load1="$(loadavg_1)"
  load5="$(loadavg_5)"
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
  err=str(d.get("error") or d.get("detail") or "error")[:80].replace(",", ";")
  print(err or "error")
PY
)
  log "${phase} [analyze p${i}]: http=${code} ms=${ms} load1=${load1} note=${note}"
  echo "${phase},${i},${code},${ms},${load1},${load5},${ACTIVE_WORKERS},${note}" >> "${CSV}"
}

run_phase() {
  local phase="$1"
  local i
  log "phase_begin ${phase}"
  for i in $(seq 1 "${PROBES_PER_PHASE}"); do
    probe_analyze "${phase}" "${i}"
  done
  log "phase_end ${phase}"
}

write_summary() {
  {
    echo "CHAOS-004 CPU starvation — summary"
    echo "generated=$(date -Iseconds)"
    echo "nproc=${NPROC}"
    echo "starved_workers=${WORKERS}"
    echo "probes_per_phase=${PROBES_PER_PHASE}"
    echo "phase_mode=${PHASE}"
    echo ""
    python3 - <<PY
import csv, statistics
from pathlib import Path
rows = list(csv.DictReader(open("${CSV}")))
for phase in ("baseline", "starved", "recovery"):
    ms = [int(r["ms"]) for r in rows if r["phase"] == phase]
    codes = [r["http"] for r in rows if r["phase"] == phase]
    loads = [float(r["load1"]) for r in rows if r["phase"] == phase]
    if not ms:
        print(f"{phase}: no samples")
        continue
    print(
        f"{phase}: n={len(ms)} http={','.join(codes)} "
        f"ms_min={min(ms)} ms_median={statistics.median(ms):.0f} ms_max={max(ms)} "
        f"load1_median={statistics.median(loads):.2f}"
    )
PY
    echo ""
    echo "csv:"
    cat "${CSV}"
    echo ""
    echo "loadavg snapshots:"
    cat "${OUT_DIR}/loadavg-snapshots.txt" 2>/dev/null || true
    echo ""
    echo "timeline:"
    cat "${TIMELINE}"
  } | tee "${SUMMARY}"
}

preflight() {
  curl -sf -m 5 "${ANALYZER_URL}/health" | tee "${OUT_DIR}/analyzer-health.json"
  echo
  python3 - <<PY
import json
d=json.load(open("${OUT_DIR}/analyzer-health.json"))
assert d.get("status") == "ok", d
assert str(d.get("warmed")).lower() in ("true", "1", "yes"), d
print("analyzer warm OK")
PY
}

trap 'stop_hog' EXIT

echo "== CHAOS-004 CPU starvation =="
echo "  Phase:        ${PHASE}"
echo "  Host Analyze: ${HOST}/api/claim-studio/analyze"
echo "  Analyzer:     ${ANALYZER_URL}/health"
echo "  Workers:      ${WORKERS} (nproc=${NPROC})"
echo "  Probes/phase: ${PROBES_PER_PHASE}"
echo ""

if [[ "${PHASE}" == "stop-hog" ]]; then
  stop_hog
  trap - EXIT
  echo "CPU hog stopped (if it was running)."
  exit 0
fi

preflight

case "${PHASE}" in
  all)
    echo "loadavg_before=$(cat /proc/loadavg)" | tee "${OUT_DIR}/loadavg-snapshots.txt"
    log "baseline_begin"
    run_phase baseline
    log "starvation_begin workers=${WORKERS}"
    start_hog "${WORKERS}"
    echo "loadavg_during=$(cat /proc/loadavg) hog_pids=$(tr '\n' ' ' < "${HOG_PID_FILE}")" | tee -a "${OUT_DIR}/loadavg-snapshots.txt"
    run_phase starved
    log "recovery_begin"
    stop_hog
    sleep "${STRESS_SETTLE_SEC}"
    echo "loadavg_after=$(cat /proc/loadavg)" | tee -a "${OUT_DIR}/loadavg-snapshots.txt"
    run_phase recovery
    ;;
  baseline)
    echo "loadavg_before=$(cat /proc/loadavg)" | tee -a "${OUT_DIR}/loadavg-snapshots.txt"
    log "baseline_begin"
    run_phase baseline
    # Keep hog stopped; disarm EXIT trap kill is fine (no-op)
    trap - EXIT
    ;;
  starved)
    log "starvation_begin workers=${WORKERS}"
    start_hog "${WORKERS}"
    echo "loadavg_during=$(cat /proc/loadavg) hog_pids=$(tr '\n' ' ' < "${HOG_PID_FILE}")" | tee -a "${OUT_DIR}/loadavg-snapshots.txt"
    run_phase starved
    # Leave hog running so you can screenshot htop; stop with --phase recovery or stop-hog
    trap - EXIT
    echo ""
    echo "NOTE: CPU hog still running — screenshot htop now, then:"
    echo "  $0 --phase recovery"
    echo "  or: $0 --phase stop-hog"
    ;;
  recovery)
    log "recovery_begin"
    stop_hog
    sleep "${STRESS_SETTLE_SEC}"
    echo "loadavg_after=$(cat /proc/loadavg)" | tee -a "${OUT_DIR}/loadavg-snapshots.txt"
    run_phase recovery
    trap - EXIT
    ;;
esac

write_summary
log "done"
echo ""
echo "Results: ${OUT_DIR}"
echo "Summary: ${SUMMARY}"

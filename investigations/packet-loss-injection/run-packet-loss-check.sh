#!/usr/bin/env bash
# CHAOS-003 — Packet loss on warm analyzer HTTP hop via delay/loss proxy :8767→:8766.
# Reuses ../network-latency-injection/delay_proxy.py (loss %). Locust NOT required.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PROXY_SRC="${HERE}/../network-latency-injection/delay_proxy.py"
OUT_DIR="${HERE}/results"
TIMELINE="${OUT_DIR}/packet-loss-timeline.log"
SUMMARY="${OUT_DIR}/packet-loss-summary.txt"
CSV="${OUT_DIR}/packet-loss-probes.csv"
PROXY_PID_FILE="${OUT_DIR}/.delay-proxy.pid"
PROXY_LOG="${OUT_DIR}/delay-proxy.log"

ANALYZER_DIRECT="${CXR_ANALYZER_URL:-http://127.0.0.1:8766}"
PROXY_URL="${CXR_PROXY_URL:-http://127.0.0.1:8767}"
PROBES_PER_PHASE="${CXR_NET_PROBES:-20}"
ANALYZE_TIMEOUT="${CXR_ANALYZE_TIMEOUT_SEC:-60}"
PHASE="all"

TIERS=(0 1 5 10 20 0)
TIER_NAMES=(baseline loss-1 loss-5 loss-10 loss-20 recovery)

usage() {
  cat <<'EOF'
CHAOS-003 — Packet loss runner

Usage:
  ./run-packet-loss-check.sh
  ./run-packet-loss-check.sh --phase baseline|loss-1|loss-5|loss-10|loss-20|recovery|stop-proxy

Env: CXR_NET_PROBES (default 20), CXR_PROXY_URL, CXR_ANALYZER_URL
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
  all|baseline|loss-1|loss-5|loss-10|loss-20|recovery|stop-proxy) ;;
  *) echo "ERROR: bad --phase ${PHASE}" >&2; exit 2 ;;
esac

mkdir -p "${OUT_DIR}"

if [[ "${PHASE}" == "all" ]]; then
  : > "${TIMELINE}"
  echo "phase,probe,http,ms,loss_pct,note" > "${CSV}"
elif [[ ! -f "${CSV}" ]]; then
  echo "phase,probe,http,ms,loss_pct,note" > "${CSV}"
  : > "${TIMELINE}"
fi

log() {
  echo "$(date -Iseconds)  $*" | tee -a "${TIMELINE}"
}

set_proxy_loss() {
  local pct="$1"
  curl -sf -m 5 -X POST "${PROXY_URL}/__cxr_proxy/loss" \
    -H 'Content-Type: application/json' \
    -d "{\"pct\": ${pct}}" >/dev/null
  # keep delay at 0 for this study
  curl -sf -m 5 -X POST "${PROXY_URL}/__cxr_proxy/delay" \
    -H 'Content-Type: application/json' \
    -d '{"ms": 0}' >/dev/null || true
  log "proxy_loss_pct=${pct}"
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
  # also clear any shared :8767 listener we didn't start
  fuser -k 8767/tcp 2>/dev/null || true
}

start_proxy() {
  # Always restart so we pick up loss-capable proxy binary.
  stop_proxy 2>/dev/null || true
  fuser -k 8767/tcp 2>/dev/null || true
  sleep 0.3
  python3 "${PROXY_SRC}" \
    --listen "127.0.0.1:${PROXY_URL##*:}" \
    --upstream "127.0.0.1:${ANALYZER_DIRECT##*:}" \
    --delay-ms 0 --loss-pct 0 >>"${PROXY_LOG}" 2>&1 &
  echo $! > "${PROXY_PID_FILE}"
  local i
  for i in $(seq 1 40); do
    if curl -sf -m 1 "${PROXY_URL}/__cxr_proxy/status" >/dev/null 2>&1; then
      log "proxy_started pid=$(cat "${PROXY_PID_FILE}")"
      return 0
    fi
    sleep 0.2
  done
  echo "ERROR: proxy failed; see ${PROXY_LOG}" >&2
  exit 1
}

probe_analyze() {
  local phase="$1"
  local i="$2"
  local loss_pct="$3"
  local out="${OUT_DIR}/analyze-${phase}-p${i}.json"
  local claim="chaos003-${phase}-p${i}-$(date +%s%N)"
  local t0 t1 ms code note
  t0=$(date +%s%3N)
  code=$(curl -sS -m "${ANALYZE_TIMEOUT}" -X POST "${PROXY_URL}/analyze" \
    -H 'Content-Type: application/json' \
    -d "{\"claim\":{\"claim_id\":\"${claim}\",\"description\":\"office visit diabetes follow up evaluation\"}}" \
    -o "${out}" -w '%{http_code}' || true)
  t1=$(date +%s%3N)
  ms=$((t1 - t0))
  # curl may print 000 on drop; never append a second 000 via || echo
  if [[ -z "${code}" || "${code}" == "000" || "${code}" == "000000" || "${code}" != "200" ]]; then
    code="000"
    note="dropped"
    echo '{"dropped":true}' > "${out}"
  else
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
  print(str(err).replace(",", ";") or "error")
PY
)
  fi
  log "${phase} [analyze p${i}]: http=${code} ms=${ms} loss_pct=${loss_pct} note=${note}"
  echo "${phase},${i},${code},${ms},${loss_pct},${note}" >> "${CSV}"
}

run_tier() {
  local phase="$1"
  local loss_pct="$2"
  local i
  set_proxy_loss "${loss_pct}"
  log "phase_begin ${phase} loss_pct=${loss_pct}"
  for i in $(seq 1 "${PROBES_PER_PHASE}"); do
    probe_analyze "${phase}" "${i}" "${loss_pct}"
  done
  log "phase_end ${phase}"
}

write_summary() {
  {
    echo "CHAOS-003 Packet loss — summary"
    echo "generated=$(date -Iseconds)"
    echo "probes_per_phase=${PROBES_PER_PHASE}"
    echo "proxy=${PROXY_URL}"
    echo "phase_mode=${PHASE}"
    echo ""
    python3 - <<PY
import csv, statistics
rows = list(csv.DictReader(open("${CSV}")))
order = ["baseline","loss-1","loss-5","loss-10","loss-20","recovery"]
seen = []
for phase in order + [r["phase"] for r in rows]:
    if phase in seen:
        continue
    if not any(r["phase"] == phase for r in rows):
        continue
    seen.append(phase)
    subset = [r for r in rows if r["phase"] == phase]
    n = len(subset)
    ok = sum(1 for r in subset if r["http"] == "200")
    ms_ok = [int(r["ms"]) for r in subset if r["http"] == "200"]
    loss = subset[0]["loss_pct"]
    med = f"{statistics.median(ms_ok):.0f}" if ms_ok else "n/a"
    print(
        f"{phase}: n={n} ok={ok} success_rate={ok/n*100:.1f}% "
        f"loss_pct={loss} ms_median_ok={med}"
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
  log "preflight OK"
}

phase_to_loss() {
  case "$1" in
    baseline|recovery) echo 0 ;;
    loss-1) echo 1 ;;
    loss-5) echo 5 ;;
    loss-10) echo 10 ;;
    loss-20) echo 20 ;;
    *) echo 0 ;;
  esac
}

trap 'if [[ "${PHASE}" == "all" ]]; then set_proxy_loss 0 2>/dev/null || true; fi' EXIT

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
    set_proxy_loss 0
    write_summary
    ;;
  *)
    preflight
    run_tier "${PHASE}" "$(phase_to_loss "${PHASE}")"
    write_summary
    ;;
esac

log "done phase=${PHASE}"
echo "Summary: ${SUMMARY}"
echo "CSV: ${CSV}"

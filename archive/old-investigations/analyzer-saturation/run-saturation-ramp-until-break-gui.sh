#!/usr/bin/env bash
# Saturation — Locust GUI: keep adding users every stage until failures or safety cap.
# Prereq: cxr up, analyzer warmed.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OPS_ROOT="${CXR_OPS_LAB:-/home/udonsi-kalu/staging/cxr-ops-lab}"
VENV="${OPS_ROOT}/load/locust/.venv"
HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
WEB_PORT="${CXR_LOCUST_WEB_PORT:-8090}"

pick_web_port() {
  local p="${WEB_PORT}"
  if [[ -n "${CXR_LOCUST_WEB_PORT:-}" ]]; then
    if curl -sf "http://127.0.0.1:${p}/" >/dev/null 2>&1; then
      echo "Port :${p} already in use (cxr lab grpcui also uses :8090)." >&2
      echo "  CXR_LOCUST_WEB_PORT=8091 $0" >&2
      exit 1
    fi
    echo "${p}"
    return
  fi
  for p in 8090 8091 8092; do
    if ! curl -sf "http://127.0.0.1:${p}/" >/dev/null 2>&1; then
      echo "${p}"
      return
    fi
  done
  echo "No free Locust web port in 8090–8092." >&2
  echo "  fuser -k 8090/tcp   OR   CXR_LOCUST_WEB_PORT=8093 $0" >&2
  exit 1
}

WEB_PORT="$(pick_web_port)"
START="${CXR_RAMP_START_USERS:-15}"
STEP="${CXR_RAMP_STEP_USERS:-5}"
STAGE="${CXR_RAMP_STAGE_SECONDS:-60}"
MAX="${CXR_RAMP_MAX_USERS:-300}"

if [[ ! -x "${VENV}/bin/locust" ]]; then
  python3 -m venv "${VENV}"
  "${VENV}/bin/pip" install -q --upgrade pip
  "${VENV}/bin/pip" install -q -r "${OPS_ROOT}/load/locust/requirements.txt"
fi

echo "== Saturation — continuous ramp (until break) =="
echo "  UI:       http://127.0.0.1:${WEB_PORT}"
echo "  Host:     ${HOST}"
echo "  Ramp:     start ${START}, +${STEP} users every ${STAGE}s, cap ${MAX}"
echo "  Watch:    Charts → Failures/s (red) and p95; click Stop when broken"
echo "  Note:     cxr up Locust is on :8089 — this script uses :${WEB_PORT}"
echo "  IMPORTANT: leave this terminal open; Ctrl+C stops Locust (UI goes away)"
echo "  Override: CXR_RAMP_MAX_USERS=500 CXR_RAMP_STEP_USERS=10 ..."
echo ""

export CXR_RAMP_START_USERS="${START}"
export CXR_RAMP_STEP_USERS="${STEP}"
export CXR_RAMP_STAGE_SECONDS="${STAGE}"
export CXR_RAMP_MAX_USERS="${MAX}"

exec "${VENV}/bin/locust" \
  -f "${HERE}/locustfile-ramp-continuous.py" \
  --host "${HOST}" \
  --web-host 127.0.0.1 \
  --web-port "${WEB_PORT}"

#!/usr/bin/env bash
# LOAD-001 — Locust web UI with auto-staged user ramp (one Start click).
# Prereq: cxr up (rehearsal :8251). Stop default Locust on :8089 if busy.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPS_ROOT="${CXR_OPS_LAB:-/home/udonsi-kalu/staging/cxr-ops-lab}"
VENV="${OPS_ROOT}/load/locust/.venv"
HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
WEB_PORT="${CXR_LOCUST_WEB_PORT:-8089}"
STAGE_SECONDS="${CXR_CAPACITY_STAGE_SECONDS:-60}"
USERS="${CXR_CAPACITY_USERS:-1 3 5 10 15}"

if [[ ! -x "${VENV}/bin/locust" ]]; then
  python3 -m venv "${VENV}"
  "${VENV}/bin/pip" install -q --upgrade pip
  "${VENV}/bin/pip" install -q -r "${OPS_ROOT}/load/locust/requirements.txt"
fi

if curl -sf "http://127.0.0.1:${WEB_PORT}/" >/dev/null 2>&1; then
  echo "Port :${WEB_PORT} in use (likely cxr up Locust)." >&2
  echo "  Option A: cxr down  (or fuser -k ${WEB_PORT}/tcp) then re-run this script" >&2
  echo "  Option B: CXR_LOCUST_WEB_PORT=8090 $0" >&2
  exit 1
fi

total=$(( $(echo "${USERS}" | wc -w) * STAGE_SECONDS ))
echo "== LOAD-001 staged Locust GUI =="
echo "  UI:      http://127.0.0.1:${WEB_PORT}"
echo "  Host:    ${HOST}"
echo "  Stages:  ${USERS} users × ${STAGE_SECONDS}s (~${total}s total)"
echo "  Action:  open UI → click **Start swarming** once (shape controls users)"
echo ""

export CXR_CAPACITY_STAGE_SECONDS="${STAGE_SECONDS}"
export CXR_CAPACITY_USERS="${USERS}"

exec "${VENV}/bin/locust" \
  -f "${SCRIPT_DIR}/locustfile-staged-gui.py" \
  --host "${HOST}" \
  --web-host 127.0.0.1 \
  --web-port "${WEB_PORT}"

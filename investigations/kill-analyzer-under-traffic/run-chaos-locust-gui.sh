#!/usr/bin/env bash
# CHAOS-001 — Locust GUI with steady users; you kill/restart analyzer manually.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OPS_ROOT="${CXR_OPS_LAB:-/home/udonsi-kalu/staging/cxr-ops-lab}"
VENV="${OPS_ROOT}/load/locust/.venv"
HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
WEB_PORT="${CXR_LOCUST_WEB_PORT:-8090}"
USERS="${CXR_CHAOS_USERS:-5}"

if [[ ! -x "${VENV}/bin/locust" ]]; then
  python3 -m venv "${VENV}"
  "${VENV}/bin/pip" install -q --upgrade pip
  "${VENV}/bin/pip" install -q -r "${OPS_ROOT}/load/locust/requirements.txt"
fi

if curl -sf "http://127.0.0.1:${WEB_PORT}/" >/dev/null 2>&1; then
  echo "Port :${WEB_PORT} in use — CXR_LOCUST_WEB_PORT=8091 $0" >&2
  exit 1
fi

echo "== CHAOS-001 Locust GUI (steady load) =="
echo "  UI:       http://127.0.0.1:${WEB_PORT}"
echo "  Users:    ${USERS} (auto via LoadTestShape)"
echo "  Steps:"
echo "    1. Start swarming"
echo "    2. After ~30s: ./kill-analyzer.sh"
echo "    3. Wait for failures in Charts"
echo "    4. ./restart-analyzer-wait-warm.sh"
echo "    5. Watch recovery; Stop when done"
echo "  IMPORTANT: leave this terminal open"
echo ""

export CXR_CHAOS_USERS="${USERS}"

exec "${VENV}/bin/locust" \
  -f "${HERE}/locustfile-chaos-steady.py" \
  --host "${HOST}" \
  --web-host 127.0.0.1 \
  --web-port "${WEB_PORT}"

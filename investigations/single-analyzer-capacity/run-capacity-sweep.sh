#!/usr/bin/env bash
# LOAD-001 — headless Locust ramp on warm stack (analyze POST only).
# Prereq: cxr up (analyzer warmed, rehearsal :8251).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPS_ROOT="${CXR_OPS_LAB:-/home/udonsi-kalu/staging/cxr-ops-lab}"
VENV="${OPS_ROOT}/load/locust/.venv"
HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
OUT_DIR="${SCRIPT_DIR}/results"
DURATION="${CXR_CAPACITY_DURATION:-90s}"
SPAWN_RATE="${CXR_CAPACITY_SPAWN_RATE:-1}"
USERS="${CXR_CAPACITY_USERS:-1 3 5 10 15}"

mkdir -p "${OUT_DIR}"

if [[ ! -x "${VENV}/bin/locust" ]]; then
  python3 -m venv "${VENV}"
  "${VENV}/bin/pip" install -q --upgrade pip
  "${VENV}/bin/pip" install -q -r "${OPS_ROOT}/load/locust/requirements.txt"
fi

if ! curl -sf "${HOST%/}/claim-studio" >/dev/null; then
  echo "ERROR: rehearsal not up at ${HOST}" >&2
  exit 1
fi

ANALYZER_URL="${ANALYZER_URL:-http://127.0.0.1:8766}"
if ! curl -sf "${ANALYZER_URL}/health" | grep -q '"warmed":"true"'; then
  echo "WARN: analyzer not warmed at ${ANALYZER_URL}/health" >&2
fi

echo "host=${HOST} duration=${DURATION} users=${USERS}"
echo "user_count,requests,failures,median_ms,p95_ms,rps" > "${OUT_DIR}/capacity-sweep.csv"

for n in ${USERS}; do
  tag="u${n}"
  echo "--- ${n} users ---"
  "${VENV}/bin/locust" \
    -f "${SCRIPT_DIR}/locustfile-analyze-only.py" \
    --host "${HOST}" \
    --headless \
    -u "${n}" \
    -r "${SPAWN_RATE}" \
    -t "${DURATION}" \
    --csv "${OUT_DIR}/${tag}" \
    --csv-full-history \
    --only-summary 2>&1 | tee "${OUT_DIR}/${tag}.log"

  stats="${OUT_DIR}/${tag}_stats.csv"
  if [[ -f "${stats}" ]]; then
    python3 - "${stats}" "${n}" "${OUT_DIR}/capacity-sweep.csv" <<'PY'
import csv, sys
stats_path, n, out_path = sys.argv[1:4]
with open(stats_path, newline="") as f:
    rows = list(csv.DictReader(f))
row = next((r for r in rows if r.get("Name") == "POST /api/claim-studio/analyze"), None)
if not row:
    row = next((r for r in rows if r.get("Name") == "Aggregated"), rows[-1] if rows else {})
def num(k, default=0):
    try:
        return float(row.get(k, default) or default)
    except ValueError:
        return default
median = num("Median Response Time")
p95 = num("95%")
reqs = int(num("Request Count"))
fails = int(num("Failure Count"))
rps = num("Requests/s")
with open(out_path, "a") as out:
    out.write(f"{n},{reqs},{fails},{median:.0f},{p95:.0f},{rps:.2f}\n")
print(f"  → median={median:.0f}ms p95={p95:.0f}ms fails={fails} rps={rps:.2f}")
PY
  fi
  sleep 5
done

echo "Wrote ${OUT_DIR}/capacity-sweep.csv"

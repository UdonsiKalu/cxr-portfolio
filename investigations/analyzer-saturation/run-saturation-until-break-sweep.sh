#!/usr/bin/env bash
# Saturation — headless: increase users step-by-step until failures appear.
# Prereq: cxr up, analyzer warmed.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
LOAD001="${HERE}/../single-analyzer-capacity"
OPS_ROOT="${CXR_OPS_LAB:-/home/udonsi-kalu/staging/cxr-ops-lab}"
VENV="${OPS_ROOT}/load/locust/.venv"
HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
OUT_DIR="${HERE}/results"
DURATION="${CXR_CAPACITY_DURATION:-90s}"
SPAWN_RATE="${CXR_CAPACITY_SPAWN_RATE:-2}"

START="${CXR_RAMP_START_USERS:-35}"
STEP="${CXR_RAMP_STEP_USERS:-5}"
MAX="${CXR_RAMP_MAX_USERS:-300}"

mkdir -p "${OUT_DIR}"

if [[ ! -x "${VENV}/bin/locust" ]]; then
  python3 -m venv "${VENV}"
  "${VENV}/bin/pip" install -q --upgrade pip
  "${VENV}/bin/pip" install -q -r "${OPS_ROOT}/load/locust/requirements.txt"
fi

echo "user_count,requests,failures,median_ms,p95_ms,rps,broke" > "${OUT_DIR}/until-break-sweep.csv"

n="${START}"
broke=0
while [[ "${n}" -le "${MAX}" ]]; do
  tag="u${n}"
  echo "--- ${n} users (stop when failures > 0) ---"
  "${VENV}/bin/locust" \
    -f "${LOAD001}/locustfile-analyze-only.py" \
    --host "${HOST}" \
    --headless \
    -u "${n}" \
    -r "${SPAWN_RATE}" \
    -t "${DURATION}" \
    --csv "${OUT_DIR}/${tag}" \
    --only-summary 2>&1 | tee "${OUT_DIR}/${tag}.log"

  stats="${OUT_DIR}/${tag}_stats.csv"
  if [[ ! -f "${stats}" ]]; then
    echo "WARN: no stats for ${n}" >&2
    n=$((n + STEP))
    continue
  fi

  python3 - "${stats}" "${n}" "${OUT_DIR}/until-break-sweep.csv" <<'PY'
import csv, sys
stats_path, n, out_path = sys.argv[1:4]
rows = list(csv.DictReader(open(stats_path, newline="")))
row = next((r for r in rows if r.get("Name") == "POST /api/claim-studio/analyze"), rows[-1] if rows else {})
def num(k, d=0):
    try: return float(row.get(k, d) or d)
    except ValueError: return d
fails = int(num("Failure Count"))
with open(out_path, "a") as out:
    out.write(f"{n},{int(num('Request Count'))},{fails},{num('Median Response Time'):.0f},{num('95%'):.0f},{num('Requests/s'):.2f},{1 if fails else 0}\n")
print(f"  → fails={fails} p95={num('95%'):.0f}ms")
if fails > 0:
    sys.exit(42)
PY
  rc=$?
  if [[ "${rc}" -eq 42 ]]; then
    echo "BREAK: failures at ${n} users"
    broke=1
    break
  fi
  n=$((n + STEP))
  sleep 5
done

if [[ "${broke}" -eq 0 ]]; then
  echo "No failures through ${MAX} users — raise CXR_RAMP_MAX_USERS or shorten think time."
fi
echo "Wrote ${OUT_DIR}/until-break-sweep.csv"

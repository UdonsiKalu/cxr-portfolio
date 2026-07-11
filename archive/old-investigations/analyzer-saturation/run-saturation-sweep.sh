#!/usr/bin/env bash
# Analyzer saturation — headless Locust ramp (15→35 users).
# Wraps LOAD-001 run-capacity-sweep.sh; writes results/ here.
# Prereq: cxr up, analyzer warmed (:8766).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
LOAD001="${HERE}/../single-analyzer-capacity"

export CXR_CAPACITY_USERS="${CXR_CAPACITY_USERS:-15 20 25 30 35}"
export CXR_CAPACITY_DURATION="${CXR_CAPACITY_DURATION:-90s}"
export CXR_CAPACITY_SPAWN_RATE="${CXR_CAPACITY_SPAWN_RATE:-1}"
export CXR_CAPACITY_OUT_DIR="${CXR_CAPACITY_OUT_DIR:-${HERE}/results}"

mkdir -p "${CXR_CAPACITY_OUT_DIR}"

echo "== Analyzer saturation sweep =="
echo "  Users:    ${CXR_CAPACITY_USERS}"
echo "  Duration: ${CXR_CAPACITY_DURATION} per tier"
echo "  Output:   ${CXR_CAPACITY_OUT_DIR}/saturation-sweep.csv"
echo ""

# Rename summary file for this investigation
export CXR_CAPACITY_OUT_DIR
"${LOAD001}/run-capacity-sweep.sh"

if [[ -f "${CXR_CAPACITY_OUT_DIR}/capacity-sweep.csv" ]]; then
  cp "${CXR_CAPACITY_OUT_DIR}/capacity-sweep.csv" "${CXR_CAPACITY_OUT_DIR}/saturation-sweep.csv"
  echo "Also saved as ${CXR_CAPACITY_OUT_DIR}/saturation-sweep.csv"
fi

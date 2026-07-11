#!/usr/bin/env bash
# Analyzer saturation — Locust GUI staged ramp (15→35 users).
# Wraps LOAD-001 run-capacity-locust-gui.sh (LoadTestShape, one Start click).
# Prereq: cxr up, analyzer warmed (:8766).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
LOAD001="${HERE}/../single-analyzer-capacity"

export CXR_CAPACITY_USERS="${CXR_CAPACITY_USERS:-15 20 25 30 35}"
export CXR_CAPACITY_STAGE_SECONDS="${CXR_CAPACITY_STAGE_SECONDS:-90}"
export CXR_CAPACITY_SPAWN_RATE="${CXR_CAPACITY_SPAWN_RATE:-1}"
export CXR_LOCUST_WEB_PORT="${CXR_LOCUST_WEB_PORT:-8090}"

echo "== Analyzer saturation — Locust GUI =="
echo "  Users:  ${CXR_CAPACITY_USERS} (staged)"
echo "  Hold:   ${CXR_CAPACITY_STAGE_SECONDS}s per tier"
echo "  UI:     http://127.0.0.1:${CXR_LOCUST_WEB_PORT}"
echo "  Action: Start swarming once → watch Charts + Jaeger :16686"
echo ""

exec "${LOAD001}/run-capacity-locust-gui.sh"

#!/usr/bin/env bash
# Restart analyzer and poll until warmed:true.
set -euo pipefail

STAGING_ROOT="${CXR_STAGING:-/home/udonsi-kalu/staging}"
CAT_ROOT="${CXR_CLAIM_ANALYSIS_TOOLS:-${STAGING_ROOT}/cxrlabs-dev/claim_analysis_tools}"
PORT="${CXR_ANALYZER_PORT:-8766}"
URL="http://127.0.0.1:${PORT}"
LOG="${CXR_ANALYZER_LOG:-/tmp/cxr-analyzer-service.log}"

if curl -sf "${URL}/health" | grep -q '"warmed":"true"'; then
  echo "Already warmed at ${URL}/health"
  exit 0
fi

echo "Starting analyzer → ${LOG}"
(
  export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://127.0.0.1:4318}"
  export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-cxr-analyzer-service}"
  export CXR_TRACE_PROFILE="${CXR_TRACE_PROFILE:-detailed}"
  cd "${CAT_ROOT}"
  nohup ./scripts/start_analyzer_service.sh >>"${LOG}" 2>&1 &
)

START=$(date +%s)
for i in $(seq 1 120); do
  if curl -sf "${URL}/health" | grep -q '"warmed":"true"'; then
    ELAPSED=$(( $(date +%s) - START ))
    echo "Warmed in ${ELAPSED}s (${URL}/health)"
    curl -sf "${URL}/health"
    echo ""
    exit 0
  fi
  if curl -sf "${URL}/health" >/dev/null 2>&1; then
    echo "  … health OK, not warmed yet (${i}s)"
  else
    echo "  … waiting for health (${i}s)"
  fi
  sleep 1
done

echo "TIMEOUT: not warmed after 120s" >&2
exit 1
